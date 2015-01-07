class AddLine < BasePage

  expected_element :dialog

  # Cost Sharing...
  element(:period) { |b| b.dialog.select(name: "newCollectionLines['budget.budgetCostShares'].projectPeriod") }
  element(:percentage) { |b| b.dialog.text_field(name: "newCollectionLines['budget.budgetCostShares'].sharePercentage") }

  # Unrecovered F&A...
  element(:fiscal_year) { |b| b.dialog.text_field(name: /fiscalYear$/) }
  element(:applicable_rate) { |b| b.dialog.text_field(name: /applicableRate$/) }
  element(:on_campus) { |b| b.dialog.select(name: /onCampusFlag$/) }
  
  # Common...
  element(:source_account) { |b| b.dialog.text_field(name: /sourceAccount$/) }
  element(:amount) { |b| b.dialog.text_field(name: /mount$/) }

  buttons 'Add', 'Cancel'

  element(:dialog) { |b| b.section(class: 'modal fade uif-cssGridGroup in') }

end