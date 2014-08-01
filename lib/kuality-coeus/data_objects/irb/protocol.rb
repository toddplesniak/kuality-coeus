class IRBProtocolObject < DataFactory

  include StringFactory, Navigation

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :other_identifier_type, :other_identifier_name, :organization_id, :organization_type,
               :funding_type, :funding_number, :source, :participant_type, :document_id, :initiator,
               :protocol_number, :status, :submission_status, :expiration_date, :personnel,
               # Submit for review...
               :reviews,
               # Withdraw
               :withdrawal_reason,
               # Amendment
               :expedited_checklist, :amend, :amendment_summary

  def_delegators :@personnel, :principal_investigator
  def_delegators :@reviews, :add_comment_for, :approve_review_of, :accept_comments_of, :comments_of,
                 :mark_comments_private_for, :mark_comments_final_for, :assign_primary_reviewers,
                 :assign_secondary_reviewers, :primary_reviewers, :secondary_reviewers

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        personnel:           collection('ProtocolPersonnel')
    }
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
      doc.expand_all
      fill_out doc, :description, :protocol_type, :title
    end
      set_pi
      set_lead_unit
    on ProtocolOverview do |doc|
      doc.save
      @protocol_number=doc.protocol_number
      @search_key = { protocol_number: @protocol_number }
    end
  end

  def view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    open_document
    on(ProtocolOverview).send(damballa(tab)) unless @browser.frm.dt(class: 'licurrent').button.alt == tab
  end

  def submit_for_review opts={}
    view 'Protocol Actions'
    @reviews = make ReviewObject, opts
    @reviews.create

    @status=on(ProtocolActions).document_status
    #document id changes here
    @document_id=on(ProtocolActions).document_id
  end

  def withdraw(reason=random_multiline(50,4))
    @withdrawal_reason=reason
    view 'Protocol Actions'
    on WithdrawProtocol do |page|
      page.expand_all
      fill_out page, :withdrawal_reason
      page.submit
      @status=page.document_status
      @document_id=page.document_id
    end
  end

  #def principal_investigator
  #  @personnel.principal_investigator
  #end

  def notify_committee
    view 'Protocol Actions'
    on NotifyCommittee do |notify|
      notify.expand_all
      notify.select_committee_id.pick! @committee_id
      notify.submit
    end
  end

  def create_amendment opts={}
    defaults = {
        amendment_summary: random_alphanums_plus,
        amend: ['General Info', 'Funding Source', 'Protocol References and Other Identifiers',
              'Protocol Organizations', 'Subjects', 'Questionnaire', 'General Info',
              'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'].sample
    }
    set_options(defaults.merge(opts))

    view 'Protocol Actions'

    on CreateAmendment do |page|
      page.expand_all
      page.amendment_summary.set @amendment_summary
      page.amend(@amend).set
      page.submit

      page.awaiting_doc
    end

    confirmation('yes')
    @document_id = on(ProtocolActions).document_id
  end

  def submit_expedited_approval  opts={}
    defaults = { }
    set_options(defaults.merge(opts))

    view 'Protocol Actions'
    on ExpeditedApproval do |page|
      # page.protocol_actions unless page.current_tab_is == 'Protocol Actions'
      page.expand_all unless page.approval_date.present?

      page.approval_date.when_present.focus
      #There is a PROBLEM when entering text in Approval Date. A popup appears saying wrong format.
      #entering text into a clear Approval Date field does not produce a popup
      page.approval_date.clear
      page.alert.ok if page.alert.exists?
      page.approval_date.fit @expedited_approval_date

      page.submit
      page.awaiting_doc
    end
  end

  def suspend
    view 'Protocol Actions'
    on ProtocolActions do |page|
      page.expand_all
      page.x
    end
  end

  def return_to_pi
    on ReturnToPI do |page|
      page.submit
      page.send_it if page.send_button.present?
      DEBUG.message @document_id.inspect

      @document_id=page.document_id
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

  # TODO: This is going to have to be updated when we want to
  # be able to specify a particular person as the PI. Right now
  # it selects a PI at random.
  def set_pi
    on(ProtocolOverview).pi_employee_search
    on KcPersonLookup do |look|
      look.search
      # We need to exclude the set of test users from the list
      # of names we'll randomly select from...
      names = look.returned_full_names - $users.full_names
      name = 'William Lloyd Garrison'
      while name.scan(' ').size > 1
        name = names.sample
        # The KcPerson_Id of the user must not contain letters...
        name = 'William Lloyd Garrison' if look.person_id_of(name) =~ /[a-z]/
      end
      first_name = name[/^\w+/]
      last_name = name[/\w+$/]
      user_name = look.user_name_of name
      look.return_value name
      pi = make ProtocolPersonnelObject, first_name: first_name, last_name: last_name,
                full_name: name, role: 'Principal Investigator', user_name: user_name
      @personnel << pi
    end
  end

end