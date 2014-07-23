When /^the (.*) user creates an IRB Protocol$/ do |role_name|
  steps %{ * I log in with the #{role_name} user }
  @irb_protocol = create IRBProtocolObject
end

When /^the Protocol Creator user creates a Protocol with an invalid lead unit code$/ do
  steps %{ * I log in with the Protocol Creator user }
  @irb_protocol = create IRBProtocolObject, lead_unit: '000000'
end

When /^the Protocol Creator creates an IRB Protocol but misses a required field$/ do
  steps %{ * I log in with the Protocol Creator user }
  # Pick a field at random for the test...
  required_field = ['Description', 'Title', 'Lead Unit'
          ].sample
  field = damballa(required_field)
  @irb_protocol = create IRBProtocolObject, field=>' '
  text = ' is a required field.'
  errors = {
      description: "Document Description (Description)#{text}",
      title: "Title (Title)#{text}",
      lead_unit: "#{required_field} (#{required_field})#{text}"
  }
  @required_field_error = errors[field]
end

And /the Protocol Creator creates an IRB Protocol in the Committee's home unit/ do
  steps '* I log in with the Protocol Creator user'
  @irb_protocol = create IRBProtocolObject, lead_unit: @committee.home_unit
end

And /the Protocol Creator creates another IRB Protocol in the Committee's home unit/ do
  steps '* I log in with the Protocol Creator user'
  @irb_protocol2 = create IRBProtocolObject, lead_unit: @committee.home_unit
end

And /^I create a IRB Protocol with Expedited Submissions Review Type$/ do
  @irb_protocol = create IRBProtocolObject, lead_unit: '000001'

  checklist_sample = Transforms::EXPEDITED_CHECKLIST.keys.sample
  puts "Checklist sapling #{checklist_sample}"
  @irb_protocol.submit_for_review  submission_type: 'Initial Protocol Application for Approval',
                                    submission_review_type: 'Expedited', expedited_checklist: Transforms::EXPEDITED_CHECKLIST.select {|k,v| k == checklist_sample }

end

And /^I assign a random Committee to the Protocol Action$/ do
  on ProtocolActions do |page|
    page.expand_all unless page.committee_id_assign.present?
    @committeelist = page.committee_id_assign.options.collect {|options| options.text}
    #Need to remove the first option from the array ('select')
    @committeelist.delete_at(0)
    page.committee_id_assign.select @committeelist.sample
    page.submit_notify_committee
  end
  #message for success
  #Protocol action Notify Committee successfully completed.
end

And /^I assign the Protocol Action to reviewers$/ do
   on ProtocolActions do |page|
     page.expand_all unless page.submit_assign_reviewers_button.present?
     page.submit_assign_reviewers
   end
end

And /^I submit a Expedited Approval with a date of last year$/ do
  #Handle too many Protocols continue? prompt if appears
  on(Confirmation).yes if on(Confirmation).yes_button.exists?
  on(Confirmation).awaiting_doc

  on ProtocolActions do |page|
    page.expand_all unless page.expedited_approval_date.present?

    page.expedited_approval_date.when_present.focus
    #There is a PROBLEM when entering in date. A popup up appears saying wrong format.
    page.expedited_approval_date.clear
    page.alert.ok if page.alert.exists?

    page.expedited_approval_date.set "#{last_year[:date_w_slashes]}"
    page.submit_expedited_approval
  end

  on ProtocolActions do |page|
    page.expand_all
    # puts     page.expire_action_date_value #debug
    # page.expire_action_date_value.should == "#{right_now[:date_w_slashes]}"
  end
end

And /^I add a Create Amendment to the IRB Protocol$/ do
  on ProtocolActions do |page|
    # page.expand_all_button.wait_until_present
    # page.expand_all
    page.expand_all_button.when_present.click

    #Create Amendment
    page.amendment_summary.set @irb_protocol.amendment_summary
    page.amend(@irb_protocol.amend).set

    page.create_amendment
  end
end

   And /^I return the Protocol Actions to the PI$/ do
     on(ProtocolActions).submit_return_to_pi
   end

And /^on the Protocol Actions I Submit for Review with:$/ do |table|
  review_data = table.rows_hash

  # view :protocol_actions #debug dataobject
  on ProtocolActions do |page|
    page.protocol_actions_tab
    page.expand_all_button.when_present.click

    # amendment select with expedited and checkbox
    @irb_protocol.submit_for_review  submission_type:   review_data['Submission Type'],
                                     submission_review_type: review_data['Review Type'],
                                     expedited_checklist: nil

  end
  on(NotificationEditor).send

end


