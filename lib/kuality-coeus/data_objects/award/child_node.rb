class AwardChildObject < AwardObject

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
                :anticipated_amount, :obligated_amount,
                :custom_data, :description, :project_start_date, :project_end_date, :obligation_start_date,
                :obligation_end_date, :time_and_money, :parent, :people_present, :key_people
  def_delegators :@key_personnel, :principal_investigator, :co_investigator

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:           'child '+random_alphanums_plus,
        account_id: 'child'+random_alphanums(10),
        reports:               collection('AwardReports'),
        press:                 'save'
    }
    @lookup_class=AwardLookup
    set_options(defaults.merge(opts))
  end
#Assumes you are on the Award
  def create
    # DEBUG.pause(5)
    view :award_actions

    on AwardActions do |page|
      page.expand_all
      # DEBUG.pause(5)
      page.award_hierarchy
      # DEBUG.pause(4)
      #copy from parent
      page.copy_from_parent.set
      page.create_child
      #now you are on the child node.
      # DEBUG.pause(4)
    end
    on Award do |page|
      page.expand_all
      page.description.fit @description
      page.account_id.fit @account_id
      page.save
    end

    on Award do |create|
      create.send(@press) unless @press.nil?
      #error messages are not displayed on first save...
      create.send(@press) unless @press.nil?
      @document_id = create.header_document_id
      # @id = create.award_id.strip
      # @search_key = { award_id: @id }
      @document_status = create.header_status
    end
  end #create

  def view(tab)
    unless on(Award).current_tab == tab
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end

  def submit
    # DEBUG.pause(9)
    view :award_actions
    DEBUG.pause(6)
    on AwardActions do |page|
      page.submit_button.wait_until_present
      page.submit
    end
    DEBUG.pause(7)

    on(Confirmation).yes if on(Confirmation).yes_button.exists?
    # DEBUG.pause(8)

  end

  def delete_all_contacts_with_role(role)
    view :contacts
    on AwardContacts do |del|
      del.expand_all

      case role
        when 'Principal Investigator'
          rolex ='PI'
        when 'Co-Investigator'
          rolex = 'COI'
        when 'Key Person'
          rolex = 'KP'
      end

      @key_people = del.get_key_people
      people_to_delete =[]
      @key_people.each_index { |i| with_role=@key_people[i].key role; (people_to_delete << @key_people[i][:name]) if with_role }
      people_to_delete.each { |name| del.delete_person(name) }
      del.save
      DEBUG.pause(5)
      DEBUG.message 'pause cause page messes up'
    end
  end


  def edit_person_project_role(name, new_role)
    view :contacts
    on AwardContacts do |edit|
      edit.expand_all
      edit.edit_project_role(name).select(new_role)
      #'Principal Investigator'
      #'Co-Investigator'
      #'Key Person'
      edit.save
      edit.lead_unit_radio_button.set
      edit.save
      DEBUG.pause(6)

    end
  end

  def sets_unit()

  end


  def set_valid_credit_split
    view :contacts
    on(AwardContacts).expand_all
    on CombinedCreditSplit do |page|
      page.set_credit_split_values('100')
      page.recalculate_splits
      page.save
    end
  end


  def add_report opts={}
    #IntellectualProperty and TechnicalManagement removed because of a validation bug in CX (https://github.com/rSmart/issues/issues/289).
    # opts[:report] ||= %w{Financial Procurement Property ProposalsDue}.sample
    DEBUG.pause(8)
    opts[:report] ||= ['Financial'].sample
    defaults = {award_id: @id, number: (@reports.count_of(opts[:report])+1).to_s}
    view :payment_reports__terms
    @reports.add defaults.merge(opts)
    DEBUG.pause(8)
  end


end #AwardChildObject

