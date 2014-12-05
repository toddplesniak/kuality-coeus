When /adds? an employee to the Budget personnel$/ do
  @budget_version.add_project_personnel
end

When /^I? ?add a non-employee to the Budget personnel$/ do
  @budget_version.add_project_personnel type: 'Non Employee'
end

When /^I? ?add a to-be-named person to the Budget personnel$/ do
  @budget_version.add_project_personnel type: 'To Be Named'
end

And /adds the '(.*)' User to the Budget personnel$/ do |type|
  user = $users.type(type)
  appointment = user.appointments.type(type)
  @budget_version.add_project_personnel full_name: user.full_name,
                                        job_code: appointment.job_code,
                                        appointment_type: appointment.type,
                                        base_salary: appointment.salary,
                                        job_title: appointment.job_title,
                                        preferred_job_title: appointment.preferred_job_title
end

And /^the Budget personnel list shows the (.*)'s job code, salary, and appointment type info$/ do |user|
  appointments=$users.type(user).appointments
  on(BudgetPersonnel).project_personnel_info.each do |item|
    if item[:person]==$users.type(user).full_name
      appointments.job_code(item[:job_code]).salary.to_f.should == item[:base_salary].to_f
      appointments.job_code(item[:job_code]).type.should == item[:appointment_type]
    end
  end
end

And /^the Budget Version personnel list shows the correct roles$/ do
  abbreviations = { 'Principal Investigator' => 'PI', 'Co-Investigator' => 'COI', 'Key Person' => 'KP' }
  @budget_version.view 'Project Personnel'
  @proposal.key_personnel.each do |person|
    on(BudgetPersonnel).proposal_role_of(person.full_name).should==abbreviations[person.role]
  end
end

And /a Project Person is assigned to Budget period (\d+), with no salary inflation$/ do |number|
  assignee = @budget_version.personnel.full_names.sample
  @budget_version.period(number).assign_person person: assignee, apply_inflation: 'No'
  @project_person = @budget_version.period(number).assigned_personnel.person(assignee)
end

And /an? '(.*)' person is assigned to Budget period (\d+)/ do |object_code, number|
  assignee = @budget_version.personnel.full_names.sample
  # TODO: Fix the whole @inflation thing. See: budget_rates.rb step definitions for where it's coming from.
  @budget_version.period(number).assign_person person: assignee, object_code: object_code, inflation_rate: @inflation
  @project_person = @budget_version.period(number).assigned_personnel.person(assignee)
end

And /^assigns a Project Person to Budget period (\d+) at (.+)% charge$/ do |number, charge|
  assignee = @budget_version.personnel.full_names.sample
  # Note: % effort must be included here to ensure it is not lower than the charged amount, because that
  # would throw an error...
  @budget_version.period(number).assign_person person: assignee, percent_effort: charge, percent_charged: charge
  @project_person = @budget_version.period(number).assigned_personnel.person(assignee)
end

And /^the Project Person's requested salary for the Budget period is as expected$/ do
  @project_person.monthly_base_salary = @budget_version.personnel.person(@project_person.person).monthly_base_salary
  on(AssignPersonnelToPeriods).requested_salary_of(@project_person.person).to_f.should be_within(0.02).of(@project_person.requested_salary)
end