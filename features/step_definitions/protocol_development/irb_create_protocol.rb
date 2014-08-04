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

And /the Protocol Creator creates an? (.*) IRB Protocol in the Committee's home unit/ do |type|
  steps '* I log in with the Protocol Creator user'
  @irb_protocol2 = create IRBProtocolObject, lead_unit: @committee.home_unit, protocol_type: type
end

# TODO: Reword this and the following scenarios to remove the "I"...
And /^I create a IRB Protocol with Expedited Submissions Review Type for lead unit '(\d+)'$/ do |lead_unit|
  @irb_protocol = create IRBProtocolObject, lead_unit: lead_unit, protocol_type: 'Expedited'

  @irb_protocol.submit_for_review  submission_type: 'Initial Protocol Application for Approval',
                                    submission_review_type: 'Expedited'

end

And /^I notify the Committee about the Protocol document$/ do
  @irb_protocol.notify_committee
end

And /^I submit a Expedited Approval with a date of last year$/ do
  @irb_protocol.submit_expedited_approval expedited_approval_date: "#{last_year[:date_w_slashes]}"
end

And /^I add a Create Amendment to the Protocol document$/ do
  @irb_protocol.create_amendment
end

And /^I return the Protocol document to the PI$/ do
  on ProtocolActions do |page|
    page.return_to_pi
    page.send_it if page.send_button.present?
  end
end

Then /^the Summary Approval Date should be last year/ do
  on(ProtocolActions).expedited_approval_date_ro.should == last_year[:date_w_slashes]
end

And /^the Expedited Date should be yesterday$/ do
  on(ProtocolActions).expedited_expiration_date_ro.should == yesterday[:date_w_slashes]
end

When /^the IRB Admin submits a Protocol to the Committee for Expedited review, with an approval date of last year$/ do
  steps %|* I log in with the IRB Administrator user
          * I create a IRB Protocol with Expedited Submissions Review Type for lead unit '000001'
          * I Notify the Committee about the Protocol document
          * assigns reviewers to the Protocol
          * I assign the Protocol Action to reviewers
          * I submit a Expedited Approval with a date of last year|
end

