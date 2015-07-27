And /^the Aggregator adds a question to the proposal person questionnaire$/ do
  steps '* log in with the Aggregator user'
  @proposal.key_personnel.questionnaire.add_question
end

And /^the Aggregator cleans up the proposal person questionnaire$/ do
  steps '* log in with the Aggregator user'
  @proposal.key_personnel.questionnaire.clean
end

And /the Proposal Creator can answer the new certification question for the personnel/ do
  steps %q|* log in with the Proposal Creator user|
  @proposal.view 'Personnel'
  on UpdateQuestionnaire do |page|
    page.copy
    page.ok
  end
  steps %q|* certifies the Proposal's|
end