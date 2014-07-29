class IRBProtocolObject < DataFactory

  include StringFactory, Navigation

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :other_identifier_type, :other_identifier_name, :organization_id, :organization_type,
               :funding_type, :funding_number, :source, :participant_type, :document_id, :initiator,
               :protocol_number, :status, :submission_status, :expiration_date, :personnel,
               # Submit for review...
               :submission_type, :submission_review_type, :type_qualifier, :committee, :schedule_date,
               :primary_reviewers, :secondary_reviewers, :reviews,
               # Withdraw
               :withdrawal_reason,
              
               :submission_type, :submission_review_type, :type_qualifier, :committee, :schedule_date,
               :expedited_checklist, :amend, :amendment_summary

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        personnel:           collection('ProtocolPersonnel'),
        primary_reviewers:   [],
        secondary_reviewers: [],
        reviews:             collection('Review')
        
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

    open_document unless @browser.frm.dt(class: 'licurrent').button.alt == tab || @browser.frm.dt(class: 'licurrent').button.alt == 'Protocol'

    on(ProtocolOverview).send(damballa(tab.to_s)) unless @browser.frm.dt(class: 'licurrent').button.alt == tab

  end

  def submit_for_review opts={}
    defaults = {
        submission_type: '::random::',
        submission_review_type:  ['Full', 'Limited/Single Use', 'FYI', 'Response'].sample,
        type_qualifier: '::random::',
        committee: '::random::',
        expedited_checklist: '::random::',
        schedule_date: '::random::'
    }
    set_options(defaults.merge(opts))
    view 'Protocol Actions'
    on ProtocolActions do |page|
      page.expand_all
      fill_out page, :submission_type, :submission_review_type, :type_qualifier,
               :committee
      # If the test doesn't specify a particular schedule date then
      # we want to pick the first selectable item
      # so as to make it most likely that there
      # will be active committee members available...
      # FIXME!!! FIXME!!! FIXME!!! FIXME!!! FIXME!!!
      # TODO: This is still buggy because sometimes the schedule dates
      # fall outside of the selectable range. FIXME!!!
      @schedule_date ||= page.schedule_date.options[1].text
      page.schedule_date.pick! @schedule_date

      if @submission_review_type == 'Expedited' && @expedited_checklist == '::random::'
        @expedited_checklist = EXPEDITED_CHECKLIST.keys.sample
        page.expedited_checklist(EXPEDITED_CHECKLIST.fetch(@expedited_checklist)).set
      end
      if @submission_review_type == 'Exempt' && @expedited_checklist == '::random::'
        #TODO:: @submission_review_type == 'Exempt' transforms.rb checklist needs to be create
        warn 'Exempt expedited checklist type needs to be created'
      end

      page.submit_for_review_submit
      page.awaiting_doc
      @status=page.document_status
    end
  end

  def assign_primary_reviewers *reviewers
    assign_reviewers 'primary', reviewers
  end

  def assign_secondary_reviewers *reviewers
    assign_reviewers 'secondary', reviewers
  end

  def withdraw(reason=random_multiline(50,4))
    @withdrawal_reason=reason
    view 'Protocol Actions'
    on ProtocolActions do |page|
      page.expand_all
      fill_out page, :withdrawal_reason
      page.submit_withdrawal_reason
      @status=page.document_status
      @document_id=page.document_id
    end
  end

  def principal_investigator
    @personnel.principal_investigator
  end

  def notify_committee opts={}
    defaults = {
        committee_id_assign: '::random::'
    }
    set_options(defaults.merge(opts))
    view 'Protocol Actions'

    on ProtocolActions do |notify|
      notify.expand_all
      fill_out notify, :committee_id_assign, :committee_action_date

        notify.notify_committee
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

    on ProtocolActions do |page|
      page.expand_all
      page.amendment_summary.set @amendment_summary
      page.amend(@amend).set
      page.create_amendment

      page.awaiting_doc
    end

    confirmation('yes')
  end

  def submit_expedited_approval opts={}
      defaults = {
      }
      set_options(defaults.merge(opts))

    #Handle too many Protocols continue? prompt if appears
    on(Confirmation).yes if on(Confirmation).yes_button.exists?
    on(Confirmation).awaiting_doc

      view 'Protocol Actions'

      on ProtocolActions do |page|
      # page.protocol_actions unless page.current_tab_is == 'Protocol Actions'
      page.expand_all unless page.expedited_approval_date.present?

      page.expedited_approval_date.when_present.focus
      #There is a PROBLEM when entering text in Approval Date. A popup appears saying wrong format.
      #entering text into a clear Approval Date field does not produce a popup
      page.expedited_approval_date.clear
      page.alert.ok if page.alert.exists?
      page.expedited_approval_date.fit @expedited_approval_date

      page.submit_expedited_approval

      page.awaiting_doc
    end
  end


  # =======
  private
  # =======

  EXPEDITED_CHECKLIST = { 'Clinical studies of drugs and medical devices'=>0, 'Continuing review of approved IRB limited to data analysis'=>1,
                          'Continuing review of research not conducted'=>2, 'Collection of blood samples'=>3, 'Prospective collection of biological specimens'=>4,
                          'Collection of data through noninvasie procedures'=>5, 'Research involving materials'=>6, 'Collection of data from voice'=>7, 'Research on individual or group'=>8,
                          'Continuing review of approved IRB permanently closed to enrollment'=>9, 'Continuing review of research previously approved'=>10 }

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

  def prep(object_class, opts)
    merge_settings(opts)
    object = make object_class, opts
    object.create
    object
  end

  def assign_reviewers type, reviewers
    rev = { 'primary' => @primary_reviewers, 'secondary' => @secondary_reviewers }
    existing_reviewers = @primary_reviewers + @secondary_reviewers
    view 'Protocol Actions'
    on ProtocolActions do |page|
      page.expand_all
      if reviewers==[]
        unselected_reviewers = (page.reviewers - existing_reviewers).shuffle
        # We want to randomize the number of reviewers selected when there
        # are several to choose from, but we don't want to select all of them
        # if we can avoid it...
        count = case(unselected_reviewers.size)
                  when 0
                    0
                  when 1, 2
                    1
                  else
                    rand(unselected_reviewers.size - 1)
                end
        count.times do |x|
          page.reviewer_type(unselected_reviewers[x]).select type
          rev[type] << unselected_reviewers[x]
        end
      else
        # Note: This code is written with the assumption
        # that the reviewer being passed is selectable and
        # isn't already a reviewer...
        reviewers.each do |reviewer|
          page.reviewer_type(reviewer).select type
          rev[type] << reviewer
          make_review_for type, reviewer
        end
      end
      page.assign_reviewers
    end
  end

  def make_review_for(type, reviewer)
    opts = {
        due_date:        @schedule_date[/^\d+-\d+-\d{4}(?=,)/].gsub('-','/'),
        reviewer:        reviewer,
        type:            type
    }
    review = make ReviewObject, opts
    @reviews << review
  end

end