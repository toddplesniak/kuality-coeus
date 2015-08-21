# coding: UTF-8
Given /I? ?add a Sponsor Contact to the Award$/ do
  @award.add_sponsor_contact
end

When /^an Account ID with special characters is added to the Award details$/ do
  @award.edit account_id: "#{random_string(5, %w{~ ! @ # $ % ^ & ž}.sample(2))}ç"
end

When /^the Award's title is made more than (\d+) characters long$/ do |arg|
  @award.edit award_title: random_string(arg.to_i+1)
end

When /I? ?adds? the required Custom Data to the Award$/ do
  @award.add_custom_data
end
#TODO: Confirm that custom data is not required in KC Award.
When /completes? the Award requirements$/ do
   # steps '* add a report to the Award'
   steps '* add Terms to the Award'
   # steps '* add the required Custom Data to the Award'
   steps '* add a Payment & Invoice item to the Award'
   steps '* add a Sponsor Contact to the Award'
   steps '* add a PI to the Award'
   steps '* give the Award valid credit splits'
end

When /completes? the nonrandom Award requirements$/ do
  # steps '* add a report to the Award'
  steps '* add nonrandom Terms to the Award'
  #TODO Look at award_terms.rb data object's create method to make changes for faster times.
  # steps '* add the required Custom Data to the Award'
  steps '* add a nonrandom Payment & Invoice item to the Award'
  steps '* add a nonrandom Sponsor Contact to the Award'
  steps '* add a PI to the Award'
  steps '* give the Award valid credit splits'
end

When /^data validation is turned on for the Award$/ do
  @award.view_tab :award_actions
  on AwardActions do |page|
    page.expand_all
    page.validation_button.wait_until_present
    page.turn_on_validation
  end
end

When /edits? the obligated amount and blank project start date on the award?/ do
  @award.edit  project_start_date: '', obligated_direct: '1000.00'
end

#----------------------#
#Subawards
#----------------------#
Given /^I? ?adds? a subaward to the Award$/ do
  @award.add_subaward
end

Given /I? ?add a nonrandom Sponsor Contact to the Award$/ do
  @award.add_sponsor_contact non_employee_id: '4056', project_role: 'Authorizing Official'
end

Given /I? ?adds? a \$(.*) Subaward to the Award$/ do |amount|
  @award.add_subaward 'random', amount
end

And /adds the same organization as a subaward again to the Award$/ do
  @award.add_subaward @award.subawards[0][:org_name]
end

And /the Award Modifier edits the finalized Award$/ do
  steps '* log in with the Award Modifier user'
  @award.edit transaction_type: '::random::', anticipated_direct: '5', obligated_direct: '5'
end

And /the Award Modifier edits the finalized Award deterministically$/ do
  steps '* log in with the Award Modifier user'
  @award.edit transaction_type: 'Correction', anticipated_direct: '5', obligated_direct: '5'
end

When /^the original Award is edited again$/ do
  on(Header).doc_search
  on DocumentSearch do |search|
    search.document_id.set @award.prior_versions['1']
    search.search
    search.open_doc @award.prior_versions['1']
  end
  on(Award).edit
end

And /^selecting 'yes' takes you to the pending version$/ do
  on(Confirmation).yes
  on Award do |page|
    expect(page.header_document_id).to eq @award.document_id
  end
end

Then /^selecting 'no' on the confirmation screen creates a new version of the Award$/ do
  on(Confirmation).no
  on Award do |page|
    expect(page.header_document_id).not_to eq @award.document_id
    expect(page.header_document_id).not_to eq @award.prior_versions[1]
  end
end

When /^the Award Modifier cancels the Award$/ do
  steps '* log in with the Award Modifier user'
  @award.cancel
end

And /^adds the unassigned user as a Principal Investigator for the Award$/ do
  @award.add_key_person first_name: 'PleaseDoNot', last_name: 'AddOrEditRoles'
end

And /adds a (.*) to the award$/ do  |role|
  @award.view_tab :contacts
  case role
    when 'PI' || 'Principal Investigator'
      @award.add_key_person project_role: 'Principal Investigator'
    when 'COI' || 'Co-Investigator'
      @award.add_key_person project_role: 'Co-Investigator'
  end
end

And /^all key personnel on the award have at least one unit$/ do
  @award.key_personnel.validate_units
end

And /^sets credit splits of the the PI to (.*) COI to (.*) and second COI to (.*)$/ do |pi, coi, coi2|
  DEBUG.message "PI #{@award.principal_investigator.units}, coi-1 #{@award.co_investigators[0].units}, coi-2 #{@award.co_investigators[1].units}"

  @award.principal_investigator.edit responsibility: pi, financial: pi
  @award.principal_investigator.update_unit_splits_to_valid(@award.principal_investigator.units)

  @award.co_investigators[0].edit responsibility: coi, financial: coi
  @award.co_investigators[0].update_unit_splits_to_valid(@award.co_investigators[0].units)

  @award.co_investigators[1].edit responsibility: coi2, financial: coi2
  @award.co_investigators[1].update_unit_splits_to_valid(@award.co_investigators[1].units)
end

And /creates a child node that is copied from the parent$/ do
  @award.add_child_from_parent description: 'child'+random_string(10), account_id: 'child'+random_alphanums(10), transaction_type: '::random::'
end

And /submits the first child with the first co-investigator as the only contact$/ do
  @award.children[0].view :contacts

  #need to remove from Data Object
  #TODO:: need to remove from data object when deleted to clean up principal_investigators[0] to just be principal_investigator.delete
  @award.children[0].principal_investigators[0].delete
  DEBUG.message "child1 cois #{@award.children[0].co_investigators.inspect}"
  @award.children[0].co_investigators[0].edit project_role: 'Principal Investigator'
  #delete the second coi, but they are now the only coi
  DEBUG.message "coi are #{@award.children[0].co_investigators.inspect}"
  @award.children[0].co_investigators[0].delete

  #TODO:: need to remove from data object on delete to clean up this cosde
  @award.children[0].principal_investigators[1].update_splits financial: '100', responsibility: '100'
  @award.children[0].principal_investigators[1].update_unit_splits_to_valid

  #need to select the lead unit
  @award.children[0].principal_investigators[1].set_lead_unit @award.children[0].principal_investigators[1].units[0][:number]
  #Child node requires a report for the submit button to be present
  @award.children[0].add_report

  @award.children[0].submit
end

And  /^submits a second child with the second co-investigator as the only contact$/ do
  @award.children[1].view :contacts
  DEBUG.message "kp child2 PI #{@award.children[1].key_personnel.principal_investigators.inspect}"
  DEBUG.pause(31)
  @award.children[1].principal_investigators[1].delete
  DEBUG.message "kp child1 PI #{@award.children[0].key_personnel.principal_investigators.inspect}"
  DEBUG.pause(32)
  @award.children[1].principal_investigators[0].delete
  DEBUG.message "kp child2 coi-1 #{@award.children[1].key_personnel.co_investigators[0].inspect}"
  DEBUG.pause(33)
  @award.children[1].key_personnel.co_investigators[0].edit project_role: 'Principal Investigator'


  #TODO:: need to remove from data object on delete to clean up this code
  @award.children[1].principal_investigators[1].update_splits financial: '100', responsibility: '100'
  @award.children[1].principal_investigators[1].update_unit_splits_to_valid

  #need to select the lead unit
  @award.children[1].principal_investigators[1].set_lead_unit @award.children[1].principal_investigators[1].units[0][:number]
  #Child node requires a report for the submit button to be present
  @award.children[1].add_report type:           'Progress/Status',
                                          frequency:      'As required',
                                          frequency_base: 'As Required',
                                          osp_file_copy:  'Report'
  @award.children[1].submit
end

And /submits the third child with the principal investigator as the only contact$/ do
  @award.children[2].co_investigators[1].delete
  @award.children[2].co_investigators[0].delete

  @award.children[2].add_report type:           'Progress/Status',
                                          frequency:      'As required',
                                          frequency_base: 'As Required',
                                          osp_file_copy:  'Report'
  @award.children[2].submit
end

