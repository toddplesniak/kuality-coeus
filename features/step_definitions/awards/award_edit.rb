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

And /adds a (.*) with a responsibility split of (\d+) and a financial split of (\d+)$/ do  |role, responsibility, financial|
  @award.view_tab :contacts
  case role
    when 'PI' || 'Principal Investigator'
      @award.add_key_person project_role: 'Principal Investigator'
      @award.set_credit_split full_name: @award.key_personnel[:principal_investigator],
                              responsibility: responsibility, financial: financial
    when 'COI' || 'Co-Investigator'
      @award.add_key_person project_role: 'Co-Investigator'
      @award.set_credit_split full_name: @award.key_personnel[:co_investigator].gsub('  ', ' '),
                              responsibility: responsibility, financial: financial
  end
end

And /adds the second (.*) with a responsibility split of (\d+) and a financial split of (\d+)$/ do  |role, responsibility, financial|
  case role
    when 'PI' || 'Principal Investigator'
      @award.add_key_person project_role: 'Principal Investigator'
      # @award.unit_recognition(@key_personnel.role.full_name,split)
      @award.set_credit_split full_name: @award.key_personnel[:principal_investigator][1],
                              responsibility: responsibility, financial: financial

    when 'COI' || 'Co-Investigator'
      @award.add_key_person project_role: 'Co-Investigator'
      @award.set_credit_split full_name: @award.key_personnel[:co_investigator].gsub('  ', ' '),
                          responsibility: responsibility, financial: financial
  end
end

And /creates a child node that is copied from the parent$/ do

  #assumes on correct award
  @child_node = create AwardChildObject, description: 'child'+random_string(10), account_id: 'child'+random_alphanums(10),   transaction_type: '::random::'
end

And /removes the co-investigators from the child node$/ do
  @child_node.delete_all_contacts_with_role('Co-Investigator')
  #Have to set credit splits to 100 after removing the childern
  @child_node.sets_unit
  @child_node.set_valid_credit_split
end

And /makes the (first|second) co-investigator the principle investigator$/ do  |person|
  @child_node.delete_all_contacts_with_role('Principal Investigator')
  @child_node.get_key_people
  rolex =[]
  @child_node.key_people.each {|x| rolex << x[:role] }
  rolex.flatten!

  case person
    when 'first'
      @child_node.edit_person_project_role(@child_node.key_people[rolex.index('Co-Investigator')][:name], 'Principal Investigator')
    when 'second'
      @child_node.edit_person_project_role(@child_node.key_people[rolex.rindex('Co-Investigator')][:name], 'Principal Investigator')
  end
  @child_node.delete_all_contacts_with_role('Co-Investigator')
  @child_node.set_valid_credit_splits
end

And /^submits the child node$/ do
  #Child node requires a report for the submit button to be present
  @child_node.add_report type:           'Progress/Status',
                         frequency:      'As required',
                         frequency_base: 'As Required',
                         osp_file_copy:  'Report'
  @child_node.submit
end