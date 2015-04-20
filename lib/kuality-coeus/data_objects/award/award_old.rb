# coding: UTF-8
class OLDAwardObject < DataFactory

  include Navigation, DateFactory, StringFactory, DocumentUtilities

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
                :anticipated_direct, :obligated_direct,
                :custom_data, :description, :project_start_date, :project_end_date, :obligation_start_date,
                :obligation_end_date, :time_and_money, :parent
  def_delegators :@key_personnel, :principal_investigator

  def initialize(browser, opts={})
    @browser = browser
    amount = random_dollar_value(1000000)

    defaults = {
      description:           random_alphanums_plus,
      transaction_type:      '::random::',
      award_status:          %w{Active Hold Pending}.sample, # Needs to be this way because we don't want it to pick a status of, e.g., 'Closed'
      award_title:           random_alphanums_plus,
      activity_type:         '::random::',
      award_type:            '::random::',
      project_start_date:    right_now[:date_w_slashes],
      project_end_date:      in_a_year[:date_w_slashes],
      sponsor_type_code:     'Federal',
      sponsor_id:            '::random::',
      lead_unit:             '::random::',
      obligation_start_date: right_now[:date_w_slashes],
      obligation_end_date:   in_a_year[:date_w_slashes],
      account_id:            random_alphanums(7),
      account_type:          '::random::',
      prime_sponsor:         '::random::',
      cfda_number:           '10.001',#"#{"%02d"%rand(99)}.#{"%03d"%rand(999)}",
      anticipated_direct:    amount,
      obligated_direct:      amount,
      funding_proposals:     [], # Contents MUST look like: {ip_number: '00001', merge_type: 'No Change'}, ...
      subawards:             [], # Contents MUST look like: {org_name: 'Org Name', amount: '999.99'}, ...
      sponsor_contacts:      [], # Contents MUST look like: {non_employee_id: '333', project_role: 'Close-out Contact'}, ...
      key_personnel:         collection('AwardKeyPersonnel'),
      cost_sharing:          collection('AwardCostSharing'),
      fa_rates:              collection('AwardFARates'),
      reports:               collection('AwardReports'),
      approved_equipment:    collection('ApprovedEquipment'),
      children:              [], # Contains the ids of any child Awards.
      version:               '1',
      prior_versions:        {} # Contains the version number and document ids of prior versions
      #budget_versions:       collection('BudgetVersions'), # This is not yet verified to work with Awards.

    }
    @lookup_class=AwardLookup
    set_options(defaults.merge(opts))
  end

  def create
    @creation_date = right_now[:date_w_slashes]
    on(Header).central_admin
    on(CentralAdmin).create_award
    on Award do |create|
      @doc_header=create.doc_title
      create.expand_all
      fill_out create, :description, :transaction_type, :award_status, :award_title,
               :activity_type, :award_type,
               #:obligated_direct, :anticipated_direct,
               #:obligated_fna, :anticipated_fna,
               :account_type,
               :project_start_date, :project_end_date, :obligation_start_date,
               :obligation_end_date, :nsf_science_code, :account_id,
               :cfda_number
      if create.obligated_direct.present?
        fill_out create, :obligated_direct, :anticipated_direct
      else
        fill_out create, :obligated_direct, :anticipated_direct,
                         :obligated_fna, :anticipated_fna
      end
    end
    set_sponsor_id
    set_prime_sponsor
    set_lead_unit
    on Award do |create|
      @funding_proposals.each do |prop|
        create.institutional_proposal_number.fit prop[:ip_number]
        create.proposal_merge_type.pick prop[:merge_type]
        create.add_proposal
      end
      @subawards.each do |sa|
        create.add_organization_name.fit sa[:org_name]
        create.add_subaward_amount.fit sa[:amount]
        create.add_subaward
      end
      create.save
      @document_id = create.header_document_id
      @id = create.award_id.strip
      @search_key = { award_id: @id }
      @document_status = create.header_status
    end
  end

  def edit opts={}

    DEBUG.message @document_id

    view :award
    on Award do |edit|

      if edit.edit_button.present?
        edit.edit
        @prior_versions.store(@version, @document_id)



        DEBUG.message @prior_versions.inspect




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

  def remove_funding_proposal(ip_number)
    view :award
    on Award do |page|
      page.expand_all
      page.delete_funding_proposal ip_number
      page.save
    end
    @funding_proposals.reject! { |item| item[:ip_number]==ip_number }
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
      page.save unless page.errors.size > 0
    end
    @subawards << {org_name: name, amount: amount}
  end

  def add_pi opts={}
    defaults = {
        document_id: @document_id,
        doc_header: @doc_header,
        lookup_class: @lookup_class
    }
    view :contacts
    @key_personnel.add defaults.merge(opts)
  end
  alias_method :add_principal_investigator, :add_pi

  def add_key_person opts={}
    defaults={project_role: 'Key Person',
              key_person_role: random_alphanums}
    add_pi defaults.merge(opts)
  end

  def add_sponsor_contact opts={}
    s_c = opts.empty? ? {non_employee_id: rand(4000..4103).to_s, project_role: '::random::'} : opts
    view :contacts
    on AwardContacts do |page|
      page.expand_all
      x = 0
      while page.org_name==' '
        page.sponsor_non_employee_id.set s_c[:non_employee_id]
        page.sponsor_non_employee_id.fire_event 'onblur'
        sleep 1
        x+=1
        raise 'Sponsor Organization is not populating!' if x == 30
      end
      page.sponsor_project_role.pick! s_c[:project_role]
      page.add_sponsor_contact
      page.save
    end
    @sponsor_contacts << s_c
  end

  def add_cost_share opts={}
    view :commitments
    @cost_sharing.add(opts)
  end

  def add_fna_rate opts={}
    view :commitments
    @fa_rates.add(opts)
  end

  def add_payment_and_invoice opts={}
    raise "You already created a Payment & Invoice in your scenario.\nYou want to interact with that item directly, now." unless @payment_and_invoice.nil?
    view :payment_reports__terms
    @payment_and_invoices = make PaymentInvoiceObject, opts
    @payment_and_invoices.create
  end

  def add_report opts={}
    #IntellectualProperty and TechnicalManagement removed because of a validation bug in CX (https://github.com/rSmart/issues/issues/289).
    opts[:report] ||= %w{Financial Procurement Property ProposalsDue}.sample
    defaults = {award_id: @id, number: (@reports.count_of(opts[:report])+1).to_s}
    view :payment_reports__terms
    @reports.add defaults.merge(opts)
  end

  def add_terms opts={}
    # raise "You already created terms in your scenario.\nYou want to interact with that object directly, now." unless @terms.nil?
    view :payment_reports__terms
    @terms = make AwardTermsObject, opts
    @terms.create
  end

  def add_approved_equipment opts={}
    view :payment_reports__terms
    @approved_equipment.add(opts)
  end

  def add_custom_data opts={}
    view :custom_data
    defaults = {
        document_id: @document_id,
        doc_header: @doc_header,
        lookup_class: @lookup_class,
        search_key: @search_key
    }
    if @custom_data.nil?
      @custom_data = make AwardCustomDataObject, defaults.merge(opts)
      @custom_data.create
    end
  end

  def initialize_time_and_money
    open_document
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

  def view(tab)
    open_document
    unless on(Award).send(StringFactory.damballa("#{tab}_element")).parent.class_name=~/tabcurrent$/
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end

  def submit
    view :award_actions
    on AwardActions do |page|
      page.expand_all
      page.award_hierarchy_link.wait_until_present
      page.submit

      # TODO: Code for intelligently handling the appearance of this (It's a screen about validation warnings)
      confirmation

      page.t_m_button.wait_until_present

      @document_status=page.header_status
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

    # Make the new data object...
    award = data_object_copy

    # Clean up the data to match...
    award.subawards = nil
    award.transaction_type = 'New'
    award.anticipated_direct = '0.00'
    award.obligated_direct = '0.00'

    on Award do |page|
      award.id = page.header_award_id
      award.document_id = page.header_document_id
      award.custom_data.document_id = page.header_document_id if award.custom_data
    end

    # Modify the new data object according to the
    # type of "copy" being done...
    case
      when type=='new' && descendents==:clear
        # Need to modify values for fields/subobjects
        # that don't copy or won't be the same...

        on Award do |page|
          # TODO: Determine if this is all we want, here...
          award.description = random_alphanums
          page.description.set award.description
          page.project_end_date.set @project_end_date
          page.save
          award.document_status=page.header_status
        end

        award.time_and_money=nil

        award.project_start_date = ''
        award.project_end_date = ''
        award.obligation_start_date = ''
        award.obligation_end_date = ''

      when type=='child_of' && descendents==:clear
        @children << award.id
        on Award do |page|
          # TODO: Determine if this is all we want, here...
          award.description = random_alphanums
          page.description.set award.description
          page.save
          award.document_status=page.header_status
        end

        award.time_and_money = @time_and_money
        award.parent = parent

      when type=='new' && descendents==:set

        on Award do |page|
          award.document_status=page.header_status
          page.award_actions
        end
        on AwardActions do |page|
          page.expand_all
          sleep 1 # FIXME!
          page.expand_tree
          sleep 2 # FIXME!
          award.children = page.descendants(award.id)
        end

        award.time_and_money=nil
        award.description = 'Copied Hierarchy' # FIXME!

      when type=='child_of' && descendents==:set
        @children << award.id
        award.description = 'Copied Hierarchy' # FIXME!
        award.time_and_money = @time_and_money
        award.parent = parent

    end
    award
  end

  def cancel
    view :award
    on Award do |page|
      page.cancel
    end
  end


  def set_valid_credit_splits_OLD
    split = (100.0/@key_personnel.with_units.size).round(2)
    splits = {}
    CREDIT_SPLITS.keys.each{ |cs| splits.store(cs, split) }

    DEBUG.message "with units array is...#{@key_personnel.with_units.inspect}..."
      @key_personnel.with_units.each do |person|
        person.update_splits splits
        units_split = (100.0/person.units.size).round(2)
        unit_splits = {}
        CREDIT_SPLITS.keys.each { |type| unit_splits.store(type, units_split) }
        DEBUG.message "the credit split keys are #{CREDIT_SPLITS}"
        person.units.each do |unit|
          DEBUG.message "00000 this is the unit that is passed #{unit[:number]}"
          correct_unit = on(CombinedCreditSplit).find_correct_unit_name(unit[:number])
          person.update_unit_splits(correct_unit, unit_splits)
        end
      end
  end


  # ========
  private
  # ========

  def set_prime_sponsor
    if @prime_sponsor=='::random::'
      on(Award).lookup_prime_sponsor
      on OLDSponsorLookup do |look|
        fill_out look, :sponsor_type_code
        look.search
        look.page_links[rand(look.page_links.length)].click if look.page_links.size > 0
        look.return_random
      end
      @prime_sponsor=on(Award).prime_sponsor.value
    else
      on(Award).prime_sponsor.fit @prime_sponsor
    end
  end

  def set_lead_unit
    if @lead_unit_id == '::random::'
      on(Award).lookup_lead_unit
      on UnitLookup do |lookup|
        lookup.search
        lookup.return_random
      end
      # DEBUG.pause(33)
      @lead_unit_id = on(Award).lead_unit_id.value
    else
      on(Award).lead_unit_id.fit @lead_unit_id
    end
  end

  def open_document
    navigate unless on_award?
    if on_tm?
      on(TimeAndMoney).return_to_award
    end
  end

  def navigate
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
  end

  def on_award?
    if on(Award).headerinfo_table.exist?
      on(Award).header_award_id==@id
    else
      false
    end
  end

  def on_tm?
    @browser.frm.button(name: 'methodToCall.returnToAward').present? && !(on(Award).t_m_button.present?)
  end

  def set_sponsor_id
    if @sponsor_id=='::random::'
      on(Award).lookup_sponsor
      on OLDSponsorLookup do |look|
        fill_out look, :sponsor_type_code
        look.search
        look.page_links[rand(look.page_links.size)].click if look.page_links.size > 0
        look.return_random
      end
      @sponsor_id=on(Award).sponsor_id.value
    else
      on(Award).sponsor_id.fit @sponsor_id
    end
  end

end