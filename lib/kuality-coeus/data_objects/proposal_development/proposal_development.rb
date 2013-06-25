class ProposalDevelopmentObject

  include Foundry
  include DataFactory
  include StringFactory
  include DateFactory
  include Navigation
  
  attr_accessor :proposal_type, :lead_unit, :activity_type, :project_title, :proposal_number,
                :sponsor_code, :sponsor_type_code, :project_start_date, :project_end_date, :document_id,
                :status, :initiator, :created, :sponsor_deadline_date, :key_personnel,
                :special_review, :budget_versions, :permissions, :s2s_questionnaire,
                :proposal_questions, :compliance_questions, :kuali_u_questions, :custom_data, :recall_reason

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      #description:           random_alphanums,
      proposal_type:         'New',
      lead_unit:             '::random::',
      activity_type:         '::random::',
      project_title:         random_alphanums,
      sponsor_code:          '::random::',
      sponsor_type_code:     '::random::',
      project_start_date:    next_week[:date_w_slashes], # TODO: Think about using the date object here, and not the string
      project_end_date:      next_year[:date_w_slashes],
      sponsor_deadline_date: next_week[:date_w_slashes],
      key_personnel:         KeyPersonnelCollection.new,
      special_review:        SpecialReviewCollection.new,
      budget_versions:       BudgetVersionsCollection.new
    }

    set_options(defaults.merge(opts))
  end
    
  def create
    on BasePage do |page|
      if page.windows.size > 1 && page.portal_window.exists?
        page.return_to_portal
        page.close_children
      elsif page.windows.size > 1
        page.use_new_tab
        page.close_parents
      end
    end
    visit(Researcher).create_proposal
    on Proposal do |doc|
      @document_id=doc.document_id
      @status=doc.document_status
      @initiator=doc.initiator
      @created=doc.created
      doc.expand_all
      fill_out doc, :proposal_type, :activity_type,
                    :project_title, :project_start_date, :project_end_date,
                    :sponsor_deadline_date#, :description
      set_sponsor_code
      set_lead_unit
      doc.save
      @proposal_number=doc.proposal_number
      @permissions = make PermissionsObject, document_id: @document_id, aggregators: [@initiator]
    end
  end

  def edit opts={}
    open_proposal
    on Proposal do |edit|
      edit.expand_all
      edit.project_start_date.fit opts[:project_start_date]
      # TODO: Add more stuff here as necessary
      edit.save
    end
    update_options(opts)
  end

  def add_key_person opts={}
    merge_settings(opts)
    kpo = make KeyPersonObject, opts
    kpo.create
    @key_personnel << kpo
  end
  # This alias is recommended only for when
  # using this method with no options.
  alias_method :add_principal_investigator, :add_key_person


  # This method simply sets all the credit splits to
  # equal values based on how many persons and units
  # are attached to the Proposal. If more complicated
  # credit splits are needed, these will have to be
  # coded in the step def, accessing the key person
  # objects directly.
  def set_valid_credit_splits
    # calculate a "person" split value that will work
    # based on the number of people attached...
    split = (100.0/@key_personnel.with_units.size).round(2)

    # Now make a hash to use for editing the person's splits...
    splits = {responsibility: split, financial: split, recognition: split, space: split}

    # Now we update the KeyPersonObjects' instance variables
    # for their own splits as well as for their units
    @key_personnel.with_units.each do |person|
      person.edit splits
      units_split = (100.0/person.units.size).round(2)
      # Make a temp container for the units we're updating...
      units = []
      person.units.each { |unit| units << {:number=>unit[:number]} }
      # Iterate through the units, updating their credit splits with the
      # valid split amount...
      units.each do |unit|
        [:responsibility, :financial, :recognition, :space].each { |item| unit[item]=units_split }
      end
      person.update_unit_credit_splits units
    end
  end

  def add_special_review opts={}
    merge_settings(opts)
    sro = make SpecialReviewObject, opts
    sro.create
    @special_review << sro
  end

  def add_budget_version opts={}
    opts[:version] ||= (@budget_versions.size+1).to_s
    merge_settings(opts)
    bvo = make BudgetVersionsObject, opts
    bvo.create
    @budget_versions << bvo
  end

  def add_custom_data opts={}
    merge_settings(opts)
    @custom_data = make CustomDataObject, opts
    @custom_data.create
  end

  def make_institutional_proposal
    # TODO: Write any preparatory web site functional steps and page scraping code
    ip = make InstitutionalProposalObject, dev_proposal_number: @proposal_number,
         proposal_type: @proposal_type,
         activity_type: @activity_type,
         project_title: @project_title,
         project_personnel: Marshal::load(Marshal.dump(@key_personnel)),
         special_review: Marshal::load(Marshal.dump(@special_review)),
         custom_data: Marshal::load(Marshal.dump(@custom_data))
         # TODO: Add more here as needed...
  end

  def delete
    open_proposal
    on(Proposal).proposal_actions
    on(ProposalActions).delete_proposal
    on(Confirmation).yes
    # Have to update the data object's status value
    # in a valid way (getting it from the system)
    visit DocumentSearch do |search|
      search.document_id.set @document_id
      search.search
      @status=search.doc_status @document_id
    end
  end

  def recall(reason=random_alphanums)
    @recall_reason=reason
    open_proposal
    on(Proposal).recall
    on Confirmation do |conf|
      conf.reason.set @recall_reason
      conf.recall_to_action_list
    end
  end

  def close
    open_proposal
    on(Proposal).close
  end

  def view(tab)
    open_proposal
    unless @status=='CANCELED' || on(Proposal).send((tab.to_s+'_button').to_sym).parent.class_name=~/tabcurrent$/
      on(Proposal).send(tab)
    end
  end

  def submit
    open_proposal
    on(Proposal).proposal_actions
    on ProposalActions do |page|
      page.submit
      page.data_validation_header.wait_until_present
      # A breaking of the design pattern, here,
      # but we have no alternative...
      @status=page.document_status
    end
  end

  # =======
  private
  # =======

  def merge_settings(opts)
    defaults = {
        document_id: @document_id
    }
    opts.merge!(defaults)
  end

  def set_sponsor_code
    if @sponsor_code=='::random::'
      on(Proposal).find_sponsor_code
      on SponsorLookup do |look|
        look.sponsor_type_code.pick! @sponsor_type_code
        look.search
        look.page_links[rand(look.page_links.length)].click if look.page_links.size > 0
        look.return_random
      end
      @sponsor_code=on(Proposal).sponsor_code.value
    else
      on(Proposal).sponsor_code.fit @sponsor_code
    end
  end

  def set_lead_unit
    on(Proposal)do |prop|
      if prop.lead_unit.present?
        prop.lead_unit.pick! @lead_unit
      else
        @lead_unit=prop.lead_unit_ro
      end
    end
  end

end