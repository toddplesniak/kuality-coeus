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
               :expedited_checklist, :amend, :amendment_summary #debug

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
        reviews:             collection('Review'),
        
        expedited_checklist: {}, #debug
        amendment_summary: random_alphanums_plus,
        amend: ['General Info', 'Funding Source', 'Protocol References and Other Identifiers', 'Protocol Organizations',
                'Subjects', 'Questionnaire', 'General Info', 'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'].sample

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
    open_document
    on(ProtocolOverview).send(damballa(tab.to_s))
  end

  def submit_for_review opts={}
    defaults = {
        submission_type: '::random::',
        submission_review_type:  ['Full', 'Limited/Single Use', 'FYI', 'Response'].sample,
        type_qualifier: '::random::',
        committee: '::random::',
        expedited_checklist: '::random::'
    }
    set_options(defaults.merge(opts))
    view :protocol_actions
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
      page.submit_for_review
      @status=page.document_status

      if @expedited_checklist == '::random::'
        @expedited_checklist.each do |item|
          puts "Item Class value is #{item} and class is... "
          puts item.class.inspect

          #needed to make a Hash because #{item} is passing in as an array
          item_hash = Hash[*item.flatten]

          puts "After hash convert, Item Class value is #{item_hash} and class is... "
          puts item_hash.class.inspect

          #fetch gets the hash item pair
          #hash.keys.sample gets the key which is then used to find the value defined in EXPEDITED_CHECKLIST
          page.expedited_checklist(Transforms::EXPEDITED_CHECKLIST.fetch(item_hash.keys.sample)).set

          # puts 'hash sample'
          # puts Transforms::EXPEDITED_CHECKLIST.fetch(item_hash.keys.sample).inspect
        end
        else
          #TODO:: Need to add defined checklist 
          puts 'not adding checklist'

        end

      page.submit_for_review_submit
      page.processing_document

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
    view :protocol_actions
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

    on ProtocolActions do |notify|
      notify.expand_all_button.when_present.click
      fill_out notify, :committee_id_assign, :committee_action_date


        notify.submit_notify_committee
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
    view :protocol_actions
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