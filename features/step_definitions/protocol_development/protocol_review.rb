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

  @comment = random_multiline(200, 10)


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
  on OnlineReview do |page|
    page.new_review_comment(pr_name).set @comment
    page.add_comment(pr_name)
    page.save_review_of(pr_name)
  end
  primary_reviewer.sign_out
end

# FIXME! The text of this stepdef is probably too vague...
And /the IRB Admin approves the review/ do
  steps '* log in with the IRB Administrator user'
  @irb_protocol.view 'Online Review'
  on OnlineReview do |page|
    page.expand_all
    page.comment_final(@comment).set
    page.comment_private(@comment).clear
    page.approve_review_of @irb_protocol.primary_reviewers[0]
  end
end