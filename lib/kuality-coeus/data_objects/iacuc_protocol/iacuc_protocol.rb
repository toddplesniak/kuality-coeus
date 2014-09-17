class IACUCProtocolObject < DataFactory

  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required,
               :procedures, :location, :document_id,
               :species, :organization, :old_organization_address


  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        protocol_project_type: '::random::',
        lay_statement_1:     random_alphanums_plus,
        alternate_search_required: 'No',
        personnel:           collection('ProtocolPersonnel')
    }
    @lookup_class = ProtocolLookup
    set_options(defaults.merge(opts))
  end

  def create
    visit(Researcher).create_iacuc_protocol

    on IACUCProtocolOverview do |doc|
      doc.expand_all_button.wait_until_present
      @document_id=doc.document_id
      @doc_header=doc.doc_title
      @status=doc.document_status
      @initiator=doc.initiator
      @submission_status=doc.submission_status
      @expiration_date=doc.expiration_date
      doc.expand_all
      fill_out doc, :description, :protocol_type, :title, :lay_statement_1
      doc.protocol_project_type.pick!(@protocol_project_type)
    end

    set_pi
    set_lead_unit

    on IACUCProtocolOverview do |doc|
      doc.save
      @protocol_number=doc.protocol_number
      @search_key = { protocol_number: @protocol_number }
    end

    #if you want to do more than just submit a protocol then this needs to be set to 'yes' or 'no'
    alternate_search_required unless @alternate_search_required.nil?
  end

  def view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    open_document
    on(IACUCProtocolOverview).send(damballa(tab)) #unless @browser.frm.dt(class: 'licurrent').button.alt == tab
  end

  def view_document
    visit(Researcher).doc_search
    on DocumentSearch do |search|
      search.document_id.set @document_id
      search.search
      search.open_item @document_id
    end
  end

  def alternate_search_required
    view("The Three R's")
    on TheThreeRs do |page|
      page.expand_all
      page.alternate_search_required.fit @alternate_search_required

      page.save
    end
  end

  def submit_for_review opts={}
    @review = {
        submission_type: '::random::',
        review_type: '::random::',
        type_qualifier: '::random::'
    }
    @review.merge!(opts)

    view('IACUC Protocol Actions')
    on IACUCSubmitForReview do |page|
      page.expand_all
      page.submission_type.pick! @review[:submission_type]
      page.review_type.pick! @review[:review_type]
      page.type_qualifier.pick! @review[:type_qualifier]
      page.submit
    end
  end

  def send_notification_to_employee
    on(IACUCProtocolOverview).send_notification
    on(NotificationEditor).employee_search

    on KcPersonLookup do |page|
      page.search
      page.return_random
    end

    on NotificationEditor do |page|
      page.add
      page.send_it
    end
  end

  def add_species_group opts={}
    @species = {
        name: random_alphanums_plus(10, 'Species '),
        species: '::random::',
        pain_category: '::random::',
        count_type: '::random::',
        count: rand(1..21)
    }
    @species.merge!(opts)

    view('Species Groups')
    on SpeciesGroups do |page|
      page.expand_all
      page.species_group_field.fit @species[:name]
      page.species_count.fit @species[:count]
      page.species.pick! @species[:species]
      page.pain_category.pick! @species[:pain_category]
      page.count_type.pick! @species[:count_type]
      page.add_species

      page.save
    end
  end

  def add_protocol_exception opts={}
    @protocol_exception = {
        exception: '::random::',
        justification: random_alphanums_plus
    }
    @protocol_exception.merge!(opts)

    view('Protocol Exception')
    on ProtocolException do |page|
      page.expand_all
      page.exception.pick! @protocol_exception[:exception]
      page.species.pick!  @species[:species]
      page.justification.fit @protocol_exception[:justification]
      page.add_exception
    end
  end

  def admin_approve
    view('IACUC Protocol Actions')
    on AdminApproveProtocol do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it
  end

  def request_to_deactivate
    view('IACUC Protocol Actions')
    on RequestToDeactivate do |page|
      page.expand_all

      #The Devs have blessed us with 2 different submit buttons
      #that display. Not sure the pattern maybe depending on the doc type/status/user
      page.submit if page.submit_button.exists?
      page.submit2 if page.submit2_button.exists?

      #First time the status changes to pending and need to deactivate a second time
      page.expand_all
      page.submit if page.submit_button.present?
      page.submit2 if page.submit2_button.present?
    end
    on(NotificationEditor).send_it
  end

  def place_hold
    view('IACUC Protocol Actions')
    on PlaceHold do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it
  end

  def lift_hold
    view('IACUC Protocol Actions')
    on LiftHold do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it if   on(NotificationEditor).send_button.present?
  end

  def add_procedure opts={}
    view('Procedures')
    @procedures = make IACUCProceduresObject, opts
    @procedures.create
  end

  #TODO:: create OrganizationObject for this complicated tab
  def add_organization opts={}
    @organization = {
        organization_id: '::random::',
        organization_type: '::random::'
    }
    @organization.merge!(opts)

    view('Protocol')
    on IACUCProtocolOverview do |page|
      page.expand_all
      if @organization[:organization_id] == '::random::'
        page.organization_lookup
        on OrganizationLookup do |lookup|
          lookup.search
          lookup.return_random
          @organization[:organization_id] = page.organization_id.value
        end
      else
        page.organization_id.fit @organization[:organization_id].value unless @organization[:organization_id].nil?
      end
      page.organization_type.pick! @organization[:organization_type] unless @organization[:organization_type].nil?
      page.add_organization
      page.save
    end
  end

  def clear_contact(org_id)
    on IACUCProtocolOverview do |page|
    @old_organization_address = page.contact_address(org_id)
    page.clear_contact(org_id)
    end
  end

  def add_contact_info(org_id)
    on(IACUCProtocolOverview).add_contact(org_id)
    on AddressBookLookup do |search|
      search.search
      search.return_random
    end
    on IACUCProtocolOverview do |page|
      @organization_address = page.contact_address(org_id)
    end
  end

end #class