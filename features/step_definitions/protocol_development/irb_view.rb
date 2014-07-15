Then /^the (.*) Checklist can be filled out$/ do |checklist|
  on(ProtocolActions).send("#{damballa(checklist)}_checklist".to_sym).should be_present
end

Then /the system warns that the number of protocols exceeds the allowed maximum/ do
  on(Confirmation).message.should=='The number of Protocols has reached or exceeded the maximum. Do you still want to submit the Protocol?'
end

Then /the non-reviewing committee member in the Protocol's personnel can't see the primary reviewer's comment in Submission Details/ do

end

And /the primary reviewer no longer sees their review comments/ do
  pr_name = @irb_protocol.primary_reviewers[0]
  primary_reviewer = @committee.members.member(pr_name)
  primary_reviewer.sign_in
  visit(Researcher).action_list




  DEBUG.pause 500




  primary_reviewer.sign_out

end

Then /the secondary reviewer (can |can't )see the primary reviewer's comment in Submission Details/ do |bool|
  type = { 'can ' => :should, 'can\'t ' => :should_not }
  sr_name = @irb_protocol.secondary_reviewers[0]
  secondary_reviewer = @committee.members.member(sr_name)
  secondary_reviewer.sign_in
  visit(Researcher).action_list
  on(ActionList).filter
  on ActionListFilter do |page|
    page.document_title.set @irb_protocol.protocol_number
    page.filter
  end
  on(ActionList).open_review(@irb_protocol.protocol_number)
  on(OnlineReview).protocol_actions
  on ProtocolActions do |page|
    page.expand_all
    page.review_comments.send(type[bool], include, @irb_protocol.reviews.review_by(@irb_protocol.primary_reviewers[0]).comments[0][:comment])
  end
  secondary_reviewer.sign_out
end

Then /the principal investigator (can |can't )see the primary reviewer's comment in Submission Details/ do |bool|
  type = { 'can ' => :should, 'can\'t ' => :should_not }
  @irb_protocol.principal_investigator.log_in
  visit Researcher
  @irb_protocol.view :protocol_actions
  on ProtocolActions do |page|
    page.expand_all
    page.review_comments.send(type[bool], include, @irb_protocol.reviews.review_by(@irb_protocol.primary_reviewers[0]).comments[0][:comment])
  end
end