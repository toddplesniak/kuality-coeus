class IACUCProtocolObject < DataFactory

  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required,
               :procedures, :location, :document_id,
               :species, :organization, :old_organization_address, :species_modify


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
    #use this view when you want to completely reload the document.
    visit(Researcher).doc_search
    on DocumentSearch do |search|
      search.document_id.set @document_id
      search.search
      search.open_item @document_id
    end
  end

  def alternate_search_required
    view "The Three R's"
    on TheThreeRs do |page|
      page.expand_all
      page.alternate_search_required.fit @alternate_search_required

      page.save
    end
  end

  def submit_for_review opts={}
    @review ||= {
        submission_type: '::random::',
        review_type: '::random::',
        type_qualifier: '::random::'
    }
    @review.merge!(opts)

    view 'IACUC Protocol Actions'
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

  def add_protocol_exception opts={}
    @protocol_exception ||= {
        exception: '::random::',
        justification: random_alphanums_plus
    }
    @protocol_exception.merge!(opts)

    view 'Protocol Exception'
    on ProtocolException do |page|
      page.expand_all
      page.exception.pick! @protocol_exception[:exception]
      page.species.pick!  @species[:species]
      page.justification.fit @protocol_exception[:justification]
      page.add_exception
    end
  end

  def admin_approve
    view 'IACUC Protocol Actions'
    on AdministrativelyApproveProtocol do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it
  end

  def request_to_deactivate
    view 'IACUC Protocol Actions'
    on RequestToDeactivate do |page|
      page.expand_all
      page.submit

      #First time the status changes to pending and need to deactivate a second time
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it
  end

  def place_hold
    view 'IACUC Protocol Actions'
    on PlaceHold do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it
  end

  def lift_hold
    view 'IACUC Protocol Actions'
    on LiftHold do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it if   on(NotificationEditor).send_button.present?
  end

  def add_organization opts={}
    view 'Protocol'
    raise 'There\'s already an Organization added to the Protocol. Please fix your scenario!' unless @organization.nil?
    @organization = make OrganizationObject, opts
    @organization.create
  end

end #IACUCProtocolObject