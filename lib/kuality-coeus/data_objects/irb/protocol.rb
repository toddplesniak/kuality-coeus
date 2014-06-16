class IRBProtocolObject < DataFactory

  include StringFactory
  include Navigation

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :other_identifier_type, :other_identifier_name, :organization_id, :organization_type,
               :funding_type, :funding_number, :source, :participant_type, :document_id, :initiator,
               :protocol_number, :status, :submission_status, :expiration_date,
               # Submit for review...
               :submission_type, :submission_review_type, :type_qualifier, :committee, :schedule_date,
               :expedited_checklist, :amend, :amendment_summary

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        expedited_checklist: [],
        amendment_summary: random_alphanums_plus,
        amend: ['General Info', 'Funding Source', 'Protocol References and Other Identifiers', 'Protocol Organizations',
                'Subjects', 'Questionnaire', 'General Info', 'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'].sample

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
        submission_review_type:  ['Full', 'Limited/Single Use', 'FYI', 'Response'].sample,
        type_qualifier: '::random::',
        committee: '::random::',
        schedule_date: '::random::',
    }
    set_options(defaults.merge(opts))
    view :protocol_actions
    on ProtocolActions do |page|
      page.expand_all
      fill_out page, :submission_type, :submission_review_type, :type_qualifier,
               :committee
      page.schedule_date.pick! @schedule_date

      @expedited_checklist.each do |item|
        #needed to make a Hash because #{item} is passing in as an array
        item_hash = Hash[*item.flatten]
        #fetch gets the hash item pair
        #hash.keys.sample gets the key which is then used to find the value defined in EXPEDITED_CHECKLIST
        page.expedited_checklist(Transforms::EXPEDITED_CHECKLIST.fetch(item_hash.keys.sample)).set

        # puts 'hash sample'
        # puts Transforms::EXPEDITED_CHECKLIST.fetch(item_hash.keys.sample).inspect

      end


      page.submit_for_review
      page.processing_document

    end
  end

  def create_amendment opts={}
    defaults = {
      amendment_summary: random_alphanums_plus,
    }
    set_options(defaults.merge(opts))

    # on(KCProtocol).protocol_actions
    # on ProtocolActions do |page|
    #   page.expand_all
    #
    #   fill_out page, :amendment_summary
    #   page.amend(@amend).set
    #
    #   sleep 30
    #   page.create_amendment
    #   # page.processing_document
    #   puts 'why you no work?'
    # end
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
    on KcPersonLookup do |look|
      look.search
      # We need to exclude the set of test users from the list
      # of names we'll randomly select from...
      names = look.returned_full_names - $users.full_names
      @principal_investigator = names.sample
      look.return_value @principal_investigator
    end
  end

  def prep(object_class, opts)
    merge_settings(opts)
    object = make object_class, opts
    object.create
    object
  end



end