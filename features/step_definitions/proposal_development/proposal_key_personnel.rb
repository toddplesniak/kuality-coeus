And /^I? ?add the (.*) user as an? (.*) to the key personnel proposal roles$/ do |user_role, proposal_role|
  user = get(user_role)
  @proposal.add_key_person first_name: user.first_name, last_name: user.last_name, role: proposal_role
end

And /adds? a key person to the Proposal$/ do
  @proposal.add_key_person role: 'Key Person', key_person_role: random_alphanums
end

When /^I? ?add (.*) as a key person with a role of (.*)$/ do |user_name, kp_role|
  user = get(user_name)
  @proposal.add_key_person first_name: user.first_name,
                           last_name: user.last_name,
                           role: 'Key Person',
                           key_person_role: kp_role
end

And /^I? ?add a (.*) with a (.*) credit split of (.*)$/ do |role, cs_type, amount|
  @split_type = cs_type
  @proposal.add_key_person cs_type.downcase.to_sym=>amount, role: role
end

When /^I? ?adds? a key person without a key person role$/ do
  @proposal.add_key_person role: 'Key Person', key_person_role:''
end

And /adds? a co-investigator to the Proposal$/ do
  @proposal.add_key_person role: 'Co-Investigator'
  on(KeyPersonnel).save
end

When /adds? a principal investigator to the Proposal$/ do
  @proposal.add_principal_investigator
end

Given /^I? ?adds? the Grants.Gov user as the Proposal's PI$/ do
  @proposal.add_principal_investigator last_name: $users.grants_gov_pi.last_name, first_name: $users.grants_gov_pi.first_name
end

When /^I? ?sets? valid credit splits for the Proposal$/ do
  @proposal.set_valid_credit_splits
end

And /can approve the Proposal$/ do
  expect{
    on(ProposalSummary).approve
  }.not_to raise_error
end

When /^the (.*) user approves the Proposal$/ do |role|
  get(role).sign_in
  @proposal.approve
end

When /add the (.*) user as a (.*) to the key personnel Proposal roles$/ do |user_role, proposal_role|
  user = get(user_role)
  @proposal.add_key_person first_name: user.first_name, last_name: user.last_name, role: proposal_role
end

Then /^the same person cannot be added to the Proposal personnel again$/ do
  @last_name = @proposal.principal_investigator.last_name
  @first_name = @proposal.principal_investigator.first_name
  expect{@proposal.add_key_person role: 'Co-Investigator', last_name: @last_name, first_name: @first_name}.to raise_error
end

And /changes the Proposal's co\-investigator to a key person$/ do
  @proposal.co_investigator.edit role: 'Key Person', key_person_role: random_alphanums
end