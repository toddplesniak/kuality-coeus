class IRBProtocolObject < DataFactory

  include StringFactory, Navigation

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :other_identifier_type, :other_identifier_name, :organization_id, :organization_type,
               :funding_type, :funding_number, :source, :participant_type, :document_id, :initiator,
               :protocol_number, :status, :submission_status, :expiration_date, :principal_investigator,
               # Submit for review...
               :submission_type, :submission_review_type, :type_qualifier, :committee, :schedule_date,
               :primary_reviewers, :secondary_reviewers,
               # Withdraw
               :withdrawal_reason

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        primary_reviewers:   [],
        secondary_reviewers: []
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
        committee: '::random::'
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
      @schedule_date ||= page.schedule_date.options[1].text
      page.schedule_date.pick! @schedule_date
      page.submit_for_review
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
        end
      end
      page.assign_reviewers
    end
  end

end