Then /^the assigned reviewers get a Protocol Review$/ do
  reviewers = @irb_protocol.review_submission.primary_reviewers + @irb_protocol.review_submission.secondary_reviewers
  reviewers.each do |rev_name|
    reviewer = @committee.members.member(rev_name)
    reviewer.sign_in
    visit(Researcher).action_list
    on(ActionList).filter
    on ActionListFilter do |page|
      page.document_title.set @irb_protocol.protocol_number
      page.filter
    end
    title_string = "KC Protocol Review - #{@irb_protocol.principal_investigator.last_name}/Protocol# #{@irb_protocol.protocol_number}"
    on(ActionList).open_review(title_string)
    on(OnlineReview).new_review_comment(rev_name).should be_present
    reviewer.sign_out
  end
end

And /the primary reviewer submits review comments/ do
  pr_name = @irb_protocol.review_submission.primary_reviewers[0]
  primary_reviewer = @committee.members.member(pr_name)
  primary_reviewer.sign_in
  visit(Researcher).action_list
  on(ActionList).filter
  on ActionListFilter do |page|
    page.document_title.set @irb_protocol.protocol_number
    page.filter
  end
  on(ActionList).open_review(@irb_protocol.protocol_number)
  @irb_protocol.review_submission.add_comment_for pr_name
  primary_reviewer.sign_out
end

And /the IRB Admin sets the flags of the primary reviewers comments to (.*)/ do |flags|
  private = flags[/Private/]
  final = flags[/Final/]
  steps '* log in with the IRB Administrator user'
  @irb_protocol.view 'Online Review'
  @irb_protocol.review_submission.primary_reviewers.each do |reviewer|
    @irb_protocol.review_submission.mark_comments_final_for(reviewer) if final
    @irb_protocol.review_submission.mark_comments_private_for(reviewer) if private
  end
end

And /the IRB Admin approves the primary reviewers (review|comment)\(s\)/ do |type|
  types = { 'review'=>:approve_review_of, 'comment'=>:accept_comments_of }
  steps '* log in with the IRB Administrator user'
  @irb_protocol.view 'Online Review'
  @irb_protocol.review_submission.primary_reviewers.each do |reviewer|
    @irb_protocol.review_submission.send(types[type], reviewer)
  end
end

And /the IRB Admin withdraws the Protocol/ do
  steps '* log in with the IRB Administrator user'
  @irb_protocol.withdraw
end