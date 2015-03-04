And /adds a non\-personnel cost to the first Budget period$/ do
  @budget_version.period(1).assign_non_personnel_cost
end

And /adds a non\-personnel cost with an? '(.*)' category type to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost category_type: type
end

And /adds a non\-personnel cost with an? '(.*)' category type and some cost sharing to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost category_type: type
  @budget_version.period(1).non_personnel_costs[0].edit cost_sharing: random_dollar_value(500000)
end

And /adds a non\-personnel cost to the first Budget period with these settings:$/ do |table|
  @add_opts = {}
  @edit_opts = {}
  @field_opts = { 'Category Type'=> :add_opts, 'Total Base Cost' => :add_opts,
                     'Apply Inflation'=>:edit_opts, 'Submit Cost Sharing'=>:edit_opts, 'Cost Sharing'=>:edit_opts }
  table.raw.each{ |item|
    get(@field_opts[item[0]]).store(damballa(item[0]), item[1]) }
  @budget_version.period(1).assign_non_personnel_cost @add_opts
  @budget_version.period(1).non_personnel_costs[0].edit @edit_opts
end

Then /^the Budget's institutional commitments shows the expected cost sharing value for Period (\d+)$/ do |period|
  # FIXME: This step only works when there are two (or less) applicable rates in the period.
  cost_sharing_f = @budget_version.period(1).non_personnel_costs[0].cost_sharing.to_f
  period_day_range = (datify(@budget_version.period(1).non_personnel_costs[0].end_date)-datify(@budget_version.period(1).non_personnel_costs[0].start_date)).to_i+1
  first_range = (datify(@end_fiscal_year_rate[:start_date])-datify(@budget_version.period(1).non_personnel_costs[0].start_date)).to_i
  second_range = (datify(@budget_version.period(1).non_personnel_costs[0].end_date)-datify(@end_fiscal_year_rate[:start_date])).to_i+1
  daily_cost_share = cost_sharing_f/period_day_range
  start_fy_rate = @start_fiscal_year_rate[:applicable_rate].to_f/100
  end_fy_rate = @end_fiscal_year_rate[:applicable_rate].to_f/100
  cost_share = cost_sharing_f + start_fy_rate*daily_cost_share*first_range + end_fy_rate*daily_cost_share*second_range
  @budget_version.view 'Cost Sharing'
  on CostSharing do |page|
    page.row_amount(period).to_f.should be_within(0.03).of cost_share
  end
end

And /^the applicable rate is the (.*)\-campus '(.*)' '(.*)' '(.*)' for the period's fiscal year\(s\)$/ do |campus, rate, rate_class_code, description|
  on_off = { 'on'=>'Yes', 'off'=>'No' }
  # Get rates...
  rates = @budget_version.institute_rates[rate].find_all { |rate|
    rate[:rate_class_code]==rate_class_code && rate[:description]==description && rate[:on_campus]==on_off[campus]
  }
  # Now gotta figure out what fiscal years are applicable and get those rates...
  @start_fiscal_year_rate = rates.find_all{ |rate|
    datify(rate[:start_date]) <= datify(@budget_version.period(1).non_personnel_costs[0].start_date)
  }[-1]
  @end_fiscal_year_rate = rates.find_all { |rate|
    datify(rate[:start_date]) <= datify(@budget_version.period(1).non_personnel_costs[0].end_date)
  }[-1]
end