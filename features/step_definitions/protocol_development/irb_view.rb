Then /^the (.*) Checklist can be filled out$/ do |checklist|
  on(ProtocolActions).send("#{damballa(checklist)}_checklist".to_sym).should be_present
end

Then /the system warns that the number of protocols exceeds the allowed maximum/ do
  on(Confirmation).message.should=='The number of Protocols has reached or exceeded the maximum. Do you still want to submit the Protocol?'
end

Then /the (.*) (can |can't )see the primary reviewer's comment in Submission Details/ do |person, bool|
  people = {
      'primary reviewer'               => @irb_protocol.primary_reviewers[0],
      'secondary reviewer'             => @irb_protocol.secondary_reviewers[0],
      'uninvolved committee member'    => (@committee.members.full_names - @irb_protocol.primary_reviewers - @irb_protocol.secondary_reviewers - @irb_protocol.personnel.names)[0],
      'non-reviewing committee member' => (@irb_protocol.personnel.names - [@irb_protocol.principal_investigator.full_name])[0]
  }
  member = people[person] ? @committee.members.member(people[person]) : @irb_protocol.principal_investigator
  member.sign_in
  @irb_protocol.view :protocol_actions
  on ProtocolActions do |page|
    page.expand_all
    page.review_comments.send(Transforms::CAN[bool], include, @irb_protocol.reviews.review_by(@irb_protocol.primary_reviewers[0]).comments[0][:comment])
  end
  member.sign_out
end