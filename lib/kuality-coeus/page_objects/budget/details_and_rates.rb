class DetailsAndRates < BasePage

  links 'General', 'Rates'
  buttons 'Close', 'Apply To Later Periods'
  
  element(:save_changes) { |b| b.div(class: 'uif-footer clearfix', data_parent: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates').button(data_dismissdialogid: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates', text: 'Save Changes').click; b.loading }

  # General
  element(:apply_inflation) { |b| b.checkbox(name: 'addProjectPersonnelHelper.budgetLineItem.applyInRateFlag') }

  # Rates


end