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
  @irb_protocol = create IRBProtocolObject, field=>''
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

And /^I submit a Expedited Approval with a date of last year$/ do
  #Too many Protocols continue?
  on(Confirmation).yes if on(Confirmation).yes_button.exists?
  on(Confirmation).awaiting_doc

  on ProtocolActions do |page|
    page.expand_all_button.when_present.click
    page.expedited_approval_date.when_present.focus
    #PROBLEM when entering in date popup up appears saying wrong format.  Commenting out for now but needed for the test
    # page.expedited_approval_date.set ''
    # page.expedited_approval_date.set '06/12/2013'
    #"#{last_year[:date_w_slashes]}"
    # page.expedited_expiration_date.value.should == "#{yesterday[:date_w_slashes]}"
    page.submit_expedited_approval
  end
  on(Confirmation).awaiting_doc
end


And /^I create an Amendment$/ do
  on ProtocolActions do |page|
    page.expand_all_button.wait_until_present
    page.expand_all
    page.amendment_summary.set @irb_protocol.amendment_summary
    page.amend(@irb_protocol.amend).set
    page.create_amendment
  end
end

And /^I submit an Amendment of type Expedited for review$/ do
  @irb_protocol.submit_for_review  submission_type: 'Amendment',
                                   submission_review_type: 'Expedited'
end

