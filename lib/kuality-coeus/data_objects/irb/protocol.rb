class IRBProtocolObject < DataFactory

  include StringFactory
  include Navigation

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
                 :other_identifier_type, :other_identifier_name, :organization_id, :organization_type,
                 :funding_type, :funding_number, :source, :participant_type, :document_id, :initiator,
                 :protocol_number, :status, :submission_status, :expiration_date,
                 # Submit for review...
                 :submission_type, :submission_review_type, :type_qualifier, :committee, :schedule_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:    random_alphanums_plus,
        protocol_type:  '::random::',
        title:          random_alphanums_plus,
        lead_unit:      '::random::',
    }
    # TODO: Needs a @lookup_class and @search_key defined
    @lookup_class = ProtocolLookup
    set_options(defaults.merge(opts))
  end

  def create
    visit(Researcher).create_irb_protocol
    on ProtocolOverview do |doc|
      @document_id=doc.document_id
      @doc_header=doc.doc_title
      @status=doc.document_status
      @initiator=doc.initiator
      @submission_status=doc.submission_status
      @expiration_date=doc.expiration_date
      @search_key = { protocol_number: @protocol_number }
      doc.expand_all
      fill_out doc, :description, :protocol_type, :title
    end
      set_lead_unit
      set_pi
    on ProtocolOverview do |doc|
      doc.save
      @protocol_number=doc.protocol_number
    end
  end

  def view(tab)
    open_document
    on(ProtocolOverview).send(damballa(tab.to_s))
  end

  def submit_for_review opts={}
    defaults = {
        submission_type: '::random::',
        submission_review_type: '::random::',
        type_qualifier: '::random::',
        committee: '::random::',
        schedule_date: '::random::'
    }
    set_options(defaults.merge(opts))
    view :protocol_actions
    on ProtocolActions do |page|
      fill_out page, :submission_type, :submission_review_type, :type_qualifier,
               :committee
      page.schedule_date.pick! @schedule_date
    end
  end

  # =======
  private
  # =======

  def merge_settings(opts)
    defaults = {
        document_id: @document_id,
        doc_header: @doc_header
    }
    opts.merge!(defaults)
  end

  def set_lead_unit
    if @lead_unit=='::random::'
      on(ProtocolOverview).find_lead_unit
      on UnitLookup do |look|
        look.search
        look.page_links[rand(look.page_links.length)].click if look.page_links.size > 0
        look.return_random
      end
      @lead_unit=on(ProtocolOverview).lead_unit.value
    else
      on(ProtocolOverview).lead_unit.fit @lead_unit
    end
  end

  def set_pi
    on(ProtocolOverview).pi_employee_search
    on PersonLookup do |look|
      look.search
      look.return_random
    end
  end

  def prep(object_class, opts)
    merge_settings(opts)
    object = make object_class, opts
    object.create
    object
  end

end