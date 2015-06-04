And /the inflation rate for the person's salary is set to (\d+) percent/ do |percentage|
  @budget_version.view 'Rates'
  on(Rates).inflation
  @project_person.rate_details.applicable_inflation_rates.each { |rate|
    rate.set_applicable_rate percentage
  }
end

Then /^the Person's Rates show correct costs and cost sharing amounts$/ do
  @budget_version.view :assign_personnel
  @project_person.monthly_base_salary = @budget_version.personnel.person(@project_person.person).monthly_base_salary
  on(AssignPersonnelToPeriods).details_and_rates_of @project_person.object_code
  on DetailsAndRates do |page|
    page.rates
    @project_person.direct_costs.each do |dc|
      expect(page.rate_amounts.find{ |r| r[:type]==dc[:description]}[:rate_cost]).to be_within(0.02).of dc[:cost]
      expect(page.rate_amounts.find{ |r| r[:type]==dc[:description]}[:rate_cost_sharing]).to be_within(0.02).of dc[:cost_share]
    end
    expect(page.rate_amounts.find{ |r| r[:type]==@budget_version.f_and_a_rate_type }[:rate_cost]).to be_within(0.02).of @project_person.indirect_costs[:cost]
    expect(page.rate_amounts.find{ |r| r[:type]==@budget_version.f_and_a_rate_type }[:rate_cost_sharing]).to be_within(0.02).of @project_person.indirect_costs[:cost_sharing]
  end
end

And /^un\-applies the '(.*)' for the '(.*)' personnel$/ do |description, object_code|
  @budget_version.view :assign_personnel
  @budget_version.period(1).assigned_personnel.details_and_rates(object_code).unapply_rate description
end

When /the '(.*)' rate for the '(.*)' personnel is unapplied$/ do |description, object_code|
  steps "* un-applies the '#{description}' for the '#{object_code}' personnel"
end

When /inflation is un\-applied for the '(.*)' personnel$/ do |object_code|
  @budget_version.view :assign_personnel
  @budget_version.period(1).assigned_personnel.details_and_rates(object_code).edit apply_inflation: 'No'
end

And /^the Period's Direct Cost is as expected$/ do
  @budget_version.view 'Periods And Totals'
  on PeriodsAndTotals do |page|
    # TODO: Don't hard code the 1...
    expect(page.direct_cost_of(1).groom).to be_within(0.02).of @budget_version.period(1).direct_cost
  end
end

And /^the Budget is synced to the new rates$/ do
     # page.buttons(text: 'Yes').each {|b| b.visible? ? b.click : b.text }
  on(SyncBudgetRates).yes_if_visible
end

And /^the Budget's rates are updated$/ do
  @budget_version.view 'Rates'
  original_rates = @budget_version.institute_rates.map { |r| r.description }
  new_rates = []
  on(Rates).rates.each { |class_type, rate|
    descriptions = rate.map{ |r| r[:description] }
    new_rates << descriptions
  }
  new_rates.flatten!
  expect(new_rates.sort).not_to eq original_rates.sort
end