When /^the Protocol is given an '(.*)' Submission Review Type$/ do |type|
  @irb_protocol.view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.submission_review_type.select type
  end
end

When /the Protocol is being submitted to that Committee for review/ do
  @irb_protocol.view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.committee.select @committee.name
  end
end

And /^submits the Protocol to the Committee for review$/ do
  @irb_protocol.submit_for_review committee: @committee.name
end

And /assigns reviewers to the Protocol/ do
  @irb_protocol.assign_primary_reviewers
  @irb_protocol.assign_secondary_reviewers
end

# Note: This stepdef assumes no reviewers are already assigned...
And /assigns a primary reviewer to the Protocol/ do
  @irb_protocol.assign_primary_reviewers @committee.members.full_names.sample
end

And /^submits the Protocol to the Committee for Expedited review$/ do
  # TODO: Add the randomized selection of the Expedited checkboxes, using Todd's code.
  @irb_protocol.submit_for_review committee: @committee.name, submission_review_type: 'Expedited'
end

When /the second Protocol is submitted to the Committee for review on the same date/ do
  @irb_protocol2.submit_for_review committee: @committee.name, schedule_date: @irb_protocol.schedule_date
end