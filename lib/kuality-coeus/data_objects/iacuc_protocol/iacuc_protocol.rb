class IACUCProtocolObject < DataFactory

  include StringFactory, DateFactory, Protocol, Utilities

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1,
               #theThreeRs
               :alternate_search_required, :reduction, :refinement, :replacement,
               #others
               :procedures, :location, :document_id, :special_review,
               :species, :organization, :old_organization_address, :species_modify, :withdrawal_reason,
               :principles, :doc, :amendment

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
        personnel:           collection('IACUCPersonnel'),
        special_review:      collection('SpecialReview')
    }

    set_options(defaults.merge(opts))
    @navigate = navigate
  end

  def create
    on(Header).researcher
    on(ResearcherMenu).create_iacuc_protocol

    on IACUCProtocolOverview do |doc|
      @document_id=doc.document_id
      @doc_header=doc.doc_title
      @status=doc.document_status
      @initiator=doc.initiator
      @submission_status=doc.submission_status
      @expiration_date=doc.expiration_date
      @protocol_number=doc.protocol_number
      doc.expand_all

      fill_out doc, :description, :protocol_type, :title, :lay_statement_1
      @protocol_project_type = doc.protocol_project_type_options.sample if @protocol_project_type == '::random::'
      fill_out doc, :protocol_project_type
    end
    unless @lead_unit==' '
      set_lead_unit
      set_pi
    end
    on(IACUCProtocolOverview).save
    on(NotificationEditor).send_notification if on(NotificationEditor).send_notification_button.present?
    on IACUCProtocolOverview do |doc|
      if doc.errors.empty?
        doc.save
        doc.send_it if doc.send_button.present? #send notification
      end
      @protocol_number=doc.protocol_number
      @search_key = { protocol_number: @protocol_number }
    end
  end

  def view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    @navigate.call
    on(IACUCProtocolOverview).send(damballa(tab))
  end

  def theThreeRs opts={}
    @principles = {
      alternate_search_required: 'No'
    }
    @principles.merge!(opts)

    view "The Three R's"
    on TheThreeRs do |page|
      page.expand_all

      page.reduction.fit @principles[:reduction]
      page.refinement.fit @principles[:refinement]
      page.replacement.fit @principles[:replacement]

      page.alternate_search_required.fit @principles[:alternate_search_required]
      page.save
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

  def add_organization opts={}
    view 'Protocol'
    raise 'There\'s already an Organization added to the Protocol. Please fix your scenario!' unless @organization.nil?
    @organization = make OrganizationObject, opts
    @organization.create
  end

  def add_special_review opts={}
    defaults = {
        navigate: @navigate,
        index: @special_review.size
    }
    @special_review.add defaults.merge(opts)
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
      @protocol_exception[:exception] = page.exception_list.sample if @protocol_exception[:exception] == '::random::'
      page.exception.pick! @protocol_exception[:exception]
      page.species.pick!  @species[:species]
      page.justification.fit @protocol_exception[:justification]
      page.add_exception
    end
  end

  # -----
  # Protocol Actions
  # -----

  def submit_for_review opts={}
    review ||= {
        submission_type: '::random::',
        review_type: '::random::',
        type_qualifier: '::random::'
    }
    review.merge!(opts)

    view 'IACUC Protocol Actions'
    on IACUCSubmitForReview do |page|
      page.expand_all
      page.submission_type.pick! review[:submission_type]
      page.review_type.pick! review[:review_type]
      page.type_qualifier.pick! review[:type_qualifier]

      page.submit
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

  def admin_approve_amendment
    view_by_protocol_number(@amendment[:protocol_number])
    view 'IACUC Protocol Actions'
    on AdministrativelyApproveProtocol do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it

    # navigate to protocol using protocol number then save document id
    # because when approving an amendment this information changes
    # and user is left on the amendment without any indication
    # of what the new document id is.
    view_by_protocol_number
    on ProtocolActions do |page|
      page.headerarea.wait_until_present
      @document_id = page.document_id
    end
  end

  def request_to_deactivate
    view 'IACUC Protocol Actions'
    on RequestToDeactivate do |page|
      page.expand_all
      page.submit
      #First time the status changes to 'pending' and need to deactivate a second time
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

  def withdraw
    view 'IACUC Protocol Actions'
    on WithdrawProtocol do |page|
      page.expand_all
      page.withdrawal_reason.fit @withdrawal_reason
      page.submit
    end
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
  end

  def lift_hold
    view 'IACUC Protocol Actions'
    on LiftHold do |page|
      page.expand_all
      page.submit
    end
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
  end

  def create_amendment opts={}
    @amendment = {
        summary: random_alphanums_plus,
        sections: [['General Info', 'Funding Source', 'Protocol References and Other Identifiers',
                    'Protocol Organizations', 'Questionnaire', 'General Info',
                    'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'].sample]
    }
    @amendment.merge!(opts)
    view 'IACUC Protocol Actions'

    on CreateAmendment do |page|
      page.expand_all
      page.summary.set @amendment[:summary]
      @amendment[:sections].each do |sect|
        page.amend(sect).set
      end
      page.create
    end
    confirmation('yes')
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
    on(CreateAmendment).save

    #Amendment has a different header with 9 fields instead of the normal 6 fields
    gather_document_info
    @amendment[:protocol_number] = @doc[:protocol_number]
    @amendment[:document_id] = @doc[:document_id]

    @document_id = on(IACUCProtocolActions).document_id
    on(IACUCProtocolOverview).send_it if on(IACUCProtocolOverview).send_button.present? #send notification
  end

  def suspend
    view 'IACUC Protocol Actions'
    on Suspend do |page|
      page.expand_all
      page.submit
    end
  end

  def expire
    view 'IACUC Protocol Actions'
    on Expire do |page|
      page.expand_all
      page.submit
    end
  end

  def terminate
    view 'IACUC Protocol Actions'
    on Terminate do |page|
      page.expand_all
      page.submit
    end
  end

  def action(page_class)
    #can be used with IACUC Protocol Actions with submit button
    #Assign to Agenda, Hold, Suspend, Expire, Terminate
    view 'IACUC Protocol Actions'
    pageKlass = Kernel.const_get(page_class.split.map(&:capitalize).join(''))
    on pageKlass do |page|
      page.expand_all

      #TODO:: Add to this method to make more robust
      page.submit
    end
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
  end

  # For Amendment document with 9 header area fields
  def gather_document_info
    keys=[]
    values=[]
    @doc={}

    on IACUCProtocolOverview do |page|
      # collecting the keys from the header table
      page.headerarea.ths.each {|k| keys << k.text.gsub(':', ' ').gsub('#', 'number').strip.gsub(' ', '_').downcase.to_sym }
      # collecting the values from the header table
      page.headerarea.tds.each {|v| values << v.text }
    end
    # turning the two arrays into a usable hash
    @doc = Hash[[keys, values].transpose]
    #removing empty key value pairs
    @doc.delete_if {|k,v| v.nil? or k==:"" }
  end

  # ============
  private
  # ============

  def navigate
    lambda {
      begin
        there = on(DocumentHeader).document_id==@document_id && @browser.frm.div(id: 'headerarea').h1.text.strip==@doc_header
      rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::StaleElementReferenceError, WatirNokogiri::Exception::UnknownObjectException, Watir::Wait::TimeoutError
        there = false
      end
      unless there
        on(BasePage).close_extra_windows
        on(Header).researcher
        on(ResearcherMenu).iacuc_search_protocols
        on ProtocolLookup do |search|
          fill_out search, :protocol_number
          search.search
          #TODO: Parameter needed for Amendment which creates a unique protocol number with 4 extra digits at the end
          #example base protocol number 1410000010 then amendment becomes 1410000010A001
          search.edit_item(@protocol_number)
        end
      end
    }
  end

end #IACUCProtocolObject