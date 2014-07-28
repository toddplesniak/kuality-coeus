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
  @irb_protocol = create IRBProtocolObject, lead_unit: '000001', protocol_type: 'Expedited'

  @irb_protocol.submit_for_review  submission_type: 'Initial Protocol Application for Approval',
                                    submission_review_type: 'Expedited'

end

And /^I Notify the Committee on the Protocol Action$/ do
  @irb_protocol.notify_committee
end

And /^I assign the Protocol Action to reviewers$/ do
   on ProtocolActions do |page|
     page.expand_all unless page.submit_assign_reviewers_button.present?
     page.submit_assign_reviewers
   end
end

And /^I submit a Expedited Approval with a date of last year$/ do
  @irb_protocol.expedited_approval expedited_approval_date: "#{last_year[:date_w_slashes]}"
end

And /^I add a Create Amendment to the IRB Protocol$/ do
  @irb_protocol.create_amendment
end

And /^I return the Protocol Actions to the PI$/ do
  on ProtocolActions do |page|
    page.submit_return_to_pi
    page.send_button.click if page.send_button.present?
  end
end

And /^on the Protocol Actions I Submit for Review with:$/ do |table|
  review_data = table.rows_hash

  on ProtocolActions do |page|
    page.protocol_actions unless page.current_tab_is == 'Protocol Actions'
    page.expand_all

    @irb_protocol.submit_for_review  submission_type:   review_data['Submission Type'],
                                     submission_review_type: review_data['Review Type'],
                                     expedited_checklist: nil
  end
end

Then /^the Summary Approval Date should be last year/ do
  on(ProtocolActions).expedited_approval_date_locked_value.should == last_year[:date_w_slashes]
end

And /^the Expedited Date should be yesterday$/ do
  on(ProtocolActions).expedited_expiration_date_locked_value.should == yesterday[:date_w_slashes]
end

When /^the IRB Admin submits a Protocol to the Committee for Expedited review, with an approval date of last year$/ do
  steps 'When I log in with the IRB Administrator user'
  steps 'And  I create a IRB Protocol with Expedited Submissions Review Type'
  steps 'And  I Notify the Committee on the Protocol Action'
  steps 'And  assigns reviewers to the Protocol'
  steps 'And  I assign the Protocol Action to reviewers'
  steps 'And  I submit a Expedited Approval with a date of last year'
end

