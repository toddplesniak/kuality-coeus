Then /^the assigned reviewers get a Protocol Review$/ do
  $users.current_user.sign_out
  reviewers = @irb_protocol.primary_reviewers + @irb_protocol.secondary_reviewers
  reviewers.each do |reviewer|
    visit($cas ? CASLogin : Login) do |log_in|
      log_in.username.set @committee.members.member(reviewer).user_name
      log_in.login
    end
    visit(Researcher).action_list
    on(ActionList).filter
    on ActionListFilter do |page|
      page.document_title.set @irb_protocol.protocol_number
      page.filter
    end
    title_string = "KC Protocol Review - #{@irb_protocol.principal_investigator[/\w+$/]}/Protocol# #{@irb_protocol.protocol_number}"
    on(ActionList).open_review(title_string)
    on(OnlineReview).new_review_comment(reviewer).should be_present
    @browser.goto "#{$base_url}#{$context}logout.do"
  end
end