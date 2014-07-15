Then /^the assigned reviewers get a Protocol Review$/ do
  reviewers = @irb_protocol.primary_reviewers + @irb_protocol.secondary_reviewers
  reviewers.each do |rev_name|
    reviewer = @committee.members.member(rev_name)
    reviewer.sign_in
    visit(Researcher).action_list
    on(ActionList).filter
    on ActionListFilter do |page|
      page.document_title.set @irb_protocol.protocol_number
      page.filter
    end
    title_string = "KC Protocol Review - #{@irb_protocol.principal_investigator[/\w+$/]}/Protocol# #{@irb_protocol.protocol_number}"
    on(ActionList).open_review(title_string)
    on(OnlineReview).new_review_comment(rev_name).should be_present
    reviewer.sign_out
  end
end

And /the primary reviewer submits review comments/ do
  pr_name = @irb_protocol.primary_reviewers[0]
  primary_reviewer = @committee.members.member(pr_name)
  primary_reviewer.sign_in
  visit(Researcher).action_list
  on(ActionList).filter
  on ActionListFilter do |page|
    page.document_title.set @irb_protocol.protocol_number
    page.filter
  end
  on(ActionList).open_review(@irb_protocol.protocol_number)
  @irb_protocol.reviews.review_by(pr_name).add_comment
  primary_reviewer.sign_out
end

And /the IRB Admin sets the flags of the primary reviewers comments to Private and Final/ do
  steps '* log in with the IRB Administrator user'
  @irb_protocol.view 'Online Review'
  @irb_protocol.primary_reviewers.each do |reviewer|
    @irb_protocol.reviews.review_by(reviewer).mark_comments_final
    @irb_protocol.reviews.review_by(reviewer).mark_comments_private
  end
end

And /the IRB Admin approves the primary reviewers (review|comment)\(s\)/ do |type|
  types = { 'review'=>:approve, 'comment'=>:accept_comments }
  steps '* log in with the IRB Administrator user'
  @irb_protocol.view 'Online Review'
  @irb_protocol.primary_reviewers.each do |reviewer|
    @irb_protocol.reviews.review_by(reviewer).send(types[type])
  end
end

And /the IRB Admin withdraws the Protocol/ do
  steps '* log in with the IRB Administrator user'
  @irb_protocol.withdraw
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