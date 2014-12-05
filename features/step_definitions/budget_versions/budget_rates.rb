And /sets the inflation rate of the Budget's on-campus administrative salaries to (\d+) percent/ do |percentage|
  @budget_version.view 'Rates'
  # FIXME: All this should not be hard-coded. Need to come up with better way to do this.
  # Probably, all this belongs encapsulated in a Data Object class for Budget Rates.
  on Rates do |page|
    page.inflation
    page.applicable_rate('Administrative Salaries', 'Yes', '2016').set percentage
  end
  @inflation = percentage
end