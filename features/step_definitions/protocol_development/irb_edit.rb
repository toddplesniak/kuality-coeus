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

# Note: This stepdef assumes no reviewers are already assigned...
And /assigns a primary and a secondary reviewer to the Protocol/ do
  # Select a random committee member who is not already in the Protocol's personnel...
  names = (@committee.members.full_names - @irb_protocol.personnel.names).shuffle
  @irb_protocol.assign_primary_reviewers names[0]
  @irb_protocol.assign_secondary_reviewers names[1]
end

And /assigns a committee member the the Protocol's personnel/ do
  # Need to make sure the selected member isn't already assigned to the Protocol somehow...
  names = @committee.members.full_names - @irb_protocol.personnel.names - @irb_protocol.primary_reviewers - @irb_protocol.secondary_reviewers
  name = names.sample
  first = name[/^\w+/]
  last = name[/\w+$/]
  role = ['Co-Investigator', 'Correspondent - CRC', 'Correspondent Administrator', 'Study Personnel'].sample
  @irb_protocol.view 'Personnel'
  @irb_protocol.personnel.add full_name: name,
                              role: role, first_name: first,
                              last_name: last
end

And /^submits the Protocol to the Committee for Expedited review$/ do
  @irb_protocol.submit_for_review committee: @committee.name, submission_review_type: 'Expedited'
end

When /the second Protocol is submitted to the Committee for review on the same date/ do
  @irb_protocol2.submit_for_review committee: @committee.name, schedule_date: @irb_protocol.schedule_date
end

And /suspends the Protocol$/ do
  @irb_protocol.suspend
end