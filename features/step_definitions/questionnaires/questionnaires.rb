And /^the Aggregator adds a question to the proposal person questionnaire$/ do
  steps '* log in with the Aggregator user'
  @proposal.key_personnel.questionnaire.add_question
end

And /^the Aggregator cleans up the proposal person questionnaire$/ do
  steps '* log in with the Aggregator user'
  @proposal.key_personnel.questionnaire.clean
end