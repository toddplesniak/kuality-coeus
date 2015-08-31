# coding: UTF-8
class AwardObject < DataFactory

  include DateFactory, StringFactory, DocumentUtilities, Utilities

  attr_reader :award_status,
              :award_title, :lead_unit_id, :activity_type, :award_type, :sponsor_id, :sponsor_type_code,
              :nsf_science_code, :account_id, :account_type, :prime_sponsor, :cfda_number,
              :version, :prior_versions,
              :creation_date, :key_personnel, :cost_sharing, :fa_rates,
              :anticipated_fna, :obligated_fna,
              :funding_proposals, #TODO: Add Benefits rates and preaward auths...
              :budget_versions, :sponsor_contacts, :payment_and_invoice, :terms, :reports,
              :approved_equipment,
              :children
  attr_accessor :document_status, :document_id, :subawards, :transaction_type, :id, :anticipated_direct, :obligated_direct,
                # These will probably need to be removed:
                :anticipated_amount, :obligated_amount,
                :custom_data, :description, :project_start_date, :project_end_date, :obligation_start_date,
                :obligation_end_date, :time_and_money, :parent, :people_present, :key_people
  def_delegators :@key_personnel, :principal_investigator, :co_investigator,  :co_investigators

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      description:           random_alphanums_plus,
      transaction_type:      '::random::',
      award_status:          %w{Active Hold Pending}.sample, # Needs to be this way because we don't want it to pick a status of, e.g., 'Closed'
      award_title:           random_high_ascii(100),
      activity_type:         '::random::',
      award_type:            '::random::',
      project_start_date:    right_now[:date_w_slashes],
      project_end_date:      in_a_year[:date_w_slashes],
      sponsor_id:            '::random::',
      lead_unit_id:          '::random::',
      version:               '1',
      prior_versions:        {}, # Contains the version number and document ids of prior versions
      fa_rates:              collection('AwardFARates'),
      cost_sharing:          collection('AwardCostSharing'),
      approved_equipment:    collection('ApprovedEquipment'),
      key_personnel:         collection('AwardKeyPersonnel'),
      reports:               collection('AwardReports'),
      children:              collection('AwardChild'),
      funding_proposals:     [], # Contents MUST be Hashes with keys :ip_number and :merge_type
      subawards:             [], # Contents MUST be Hashes with keys :org_name and :amount
      sponsor_contacts:      [], # Contents MUST be Hashes with keys :non_employee_id and :project_role
      press: 'save'
    }
    set_options(defaults.merge(opts))
    @navigate = navigate
  end
#
  def create
    on(Header).central_admin
    on(CentralAdmin).create_award
    on Award do |create|
      create.expand_all
      fill_out create, :description, :transaction_type,
               :award_status, :activity_type, :award_type,
               :award_title, :project_start_date, :project_end_date,
               :obligation_start_date, :obligation_end_date, :obligated_direct,
               :anticipated_direct
    end
    set_lead_unit
    set_sponsor_id
    on Award do |create|
      create.send(@press) unless @press.nil?
      #error messages are not displayed on first save...
      create.send(@press) unless @press.nil?
      @document_id = create.header_document_id
      @id = create.award_id.strip
      @document_status = create.header_status
    end
  end #create

  def edit opts={}
    view :award
    @prior_versions.store(@version, @document_id)
    on Award do |edit|
      if edit.edit_button.present?
        edit.edit
        @prior_versions.store(@version, @document_id)

        @version = edit.version
        @document_id = edit.header_document_id
        # TODO: update child objects with new @document_id value!
      end
      edit_fields opts, edit, :description, :transaction_type, :award_status, :award_title,
                  :activity_type, :award_type, :obligated_direct, :anticipated_direct,
                  :project_start_date, :project_end_date, :obligation_start_date,
                  :obligation_end_date, :nsf_science_code, :account_id, :account_type,
                  :cfda_number, :obligated_fna, :anticipated_fna
      edit.save
    end
    set_options(opts)
  end

  def view(tab)
    @navigate.call
    return if on(Award).error_message.present?
    unless on(Award).current_tab == tab
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end

  def copy(type='new', parent=nil, descendents=:clear)
    view :award_actions
    on AwardActions do |copy|
      copy.close_parents
      copy.expand_all
      copy.expand_tree
      sleep 3 # FIXME!
      copy.show_award_details_panel(@id) unless copy.award_div(@id).visible?
      copy.copy_descendents(@id).send(descendents) if copy.copy_descendents(@id).enabled?
      copy.send("copy_as_#{type}", @id)
      copy.child_of_target_award(@id).pick! parent
      copy.copy_award @id
    end
  end

  def set_lead_unit
    if @lead_unit_id == '::random::'
      on(Award).lookup_lead_unit
      on UnitLookup do |lookup|
        lookup.search
        lookup.return_random
      end
      on Award do |page|
        page.lead_unit_id.wait_until_present
        @lead_unit_id = page.lead_unit_id.value
      end
    else
      on(Award).lead_unit_id.fit @lead_unit_id
    end
  end

  def set_sponsor_id
    if @sponsor_id=='::random::'
      on(Award).lookup_sponsor
      on OLDSponsorLookup do |look|
        fill_out look, :sponsor_type_code
        look.search
        look.return_random
      end
      @sponsor_id=on(Award).sponsor_id.value
    else
      on(Award).sponsor_id.fit @sponsor_id
    end
  end

  def add_payment_and_invoice opts={}
    raise "You already created a Payment & Invoice in your scenario.\nYou want to interact with that item directly, now." unless @payment_and_invoice.nil?
    view :payment_reports__terms
    @payment_and_invoices = make PaymentInvoiceObject, opts
    @payment_and_invoices.create
  end

  def add_sponsor_contact opts={}
    s_c = opts.empty? ? {non_employee_id: rand(4000..4103).to_s, project_role: '::random::'} : opts
    view :contacts
    on AwardContacts do |page|
      page.expand_all
      page.search_sponsor_contact
    end
    on NonOrgAddressBookLookup do |lookup|
      lookup.search
      lookup.return_random
    end

    on AwardContacts do |page|
      page.sponsor_project_role.pick! s_c[:project_role]
      page.add_sponsor_contact
      page.save
    end
  end

  def add_report opts={}
    view :payment_reports__terms
    @reports.add opts
  end

   def add_terms opts={}
    raise "You already created terms in your scenario.\nYou want to interact with that object directly, now." unless @terms.nil?
    view :payment_reports__terms
    @terms = make AwardTermsObject, opts
    @terms.create
  end

  def set_valid_credit_splits
    view :contacts
    on(AwardContacts).expand_all
    on CombinedCreditSplit do |page|
      page.set_credit_split_values('100')
      page.recalculate_splits
      page.save
    end
  end

  def submit
    # DEBUG.pause(14)
    view :award_actions
    # DEBUG.pause(14)
    on(AwardActions).submit
    # DEBUG.pause(14)
    on(Confirmation).yes if on(Confirmation).yes_button.exists?
    # DEBUG.pause(14)
    # raise 'Award submission failed.' unless on(AwardActions).notification=='Document was successfully submitted.'
    raise 'Award not submitted' if on(AwardActions).errors.size > 0
  end

  def add_custom_data opts={}
    view :custom_data
    defaults = {
        document_id: @document_id,
        doc_header: @doc_header
    }
    if @custom_data.nil?
      @custom_data = make AwardCustomDataObject, defaults.merge(opts)
      @custom_data.create
    end
  end

  def initialize_time_and_money
    @navigate.call
    on(Award).time_and_money
    # Set up to only create the instance variable if it doesn't exist, yet
    if @time_and_money.nil?
      @time_and_money = make TimeAndMoneyObject, document_id: on(TimeAndMoney).header_document_id,
                             award_number: @id
      @time_and_money.create
    else
      @time_and_money.check_status
    end
  end

  def add_fna_rate opts={}
    view :commitments
    @fa_rates.add(opts)
  end

  def add_cost_share opts={}
    view :commitments
    @cost_sharing.add(opts)
  end

  def add_funding_proposal(ip_number, merge_type)
    view :award
    on Award do |page|
      page.expand_all
      page.institutional_proposal_number.fit ip_number
      page.proposal_merge_type.pick merge_type
      page.add_proposal
      page.save if page.errors.empty?
    end
    @funding_proposals << {ip_number: ip_number, merge_type: merge_type}
  end

  def add_subaward(name='random', amount=nil)
    amount ||= random_dollar_value(10000000)
    view :award
    on Award do |page|
      page.expand_all
      page.search_organization
    end
    if name=='random'
      on OrganizationLookup do |page|
        page.search
        page.return_random
      end
      name = on(Award).add_organization_name.value
    else
      on OrganizationLookup do |page|
        page.organization_name.set name
        page.search
        page.return_value name
      end
    end
    on Award do |page|
      page.add_subaward_amount.fit amount
      page.add_subaward
      page.save #unless page.errors.size > 0
    end
    @subawards << {org_name: name, amount: amount}
  end

  def add_approved_equipment opts={}
    view :payment_reports__terms
    @approved_equipment.add(opts)
  end

  def add_key_person opts={}
    view :contacts
    defaults = {
        navigate: @navigate
                     }
    @key_personnel.add defaults.merge!(opts)
  end

  def add_child_from_parent opts={}
    view :award_actions
    # award_copy = data_object_copy
    # DEBUG.inspect award_copy
    defaults = { description: 'child'+random_alphanums(20), navigate: @navigate, key_personnel: @key_personnel.dup }
    @children.add defaults.merge!(opts)
  end

  # ==============
  private
  # ==============

  def navigate
    lambda {
      begin
        there = on(Award).header_document_id==@document_id
      rescue
        there = false
      end
      unless there
        # If we are in a strange place without a header because of time and money, need to get back from there...
        @browser.goto $base_url+$context unless on(Header).header_div.present?

        if on(Header).krad_portal_element.present?
          on(Header).krad_portal
        end
        on(Header).central_admin
        on(CentralAdmin).search_award
        on AwardLookup do |page|
          page.award_id.set @id
          page.search
          # TODO: Remove this when document search issues are resolved
          begin
            page.medusa
          rescue Watir::Exception::UnknownObjectException
            on(Header).doc_search
            on DocumentSearch do |search|
              search.document_id.set @document_id
              search.search

              search.open_item @document_id
            end
          end
        end
        return if on(Award).error_message.present?
        on(Award).div(class: 'headerbox').table(class: 'headerinfo').wait_until_present
      end
    }
  end

end #AwardObject