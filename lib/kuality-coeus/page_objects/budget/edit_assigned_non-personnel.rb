class EditAssignedNonPersonnel < BasePage

  buttons 'Save Changes'

  action(:details_tab) { |b| b.tab_list.li(text: 'Details').link.click }
  action(:cost_sharing_tab) { |b| b.tab_list.li(text: 'Cost Sharing').link.click }
  action(:rates_tab) { |b| b.tab_list.li(text: 'Rates').link.click; b.rates_table.wait_until_present(15) }

  # Details
  element(:start_date) { |b| b.text_field(name: 'addProjectBudgetLineItemHelper.budgetLineItem.startDate') }
  element(:end_date) { |b| b.text_field(name: 'addProjectBudgetLineItemHelper.budgetLineItem.endDate') }
  element(:budget_category) { |b| b.select(name: 'addProjectBudgetLineItemHelper.budgetLineItem.budgetCategoryCode') }
  element(:object_code_name) { |b| b.select(name: 'addProjectBudgetLineItemHelper.budgetLineItem.costElement') }
  element(:total_base_cost) { |b| b.text_field(name: 'addProjectBudgetLineItemHelper.budgetLineItem.lineItemCost') }
  
  element(:apply_inflation) { |b| b.checkbox(name: 'addProjectBudgetLineItemHelper.budgetLineItem.applyInRateFlag') }
  element(:submit_cost_sharing) { |b| b.checkbox(name: 'addProjectBudgetLineItemHelper.budgetLineItem.applyInRateFlag') }
  element(:on_campus) { |b| b.checkbox(name: 'addProjectBudgetLineItemHelper.budgetLineItem.onOffCampusFlag') }

  # Cost Sharing
  element(:cost_sharing) { |b| b.text_field(name: 'addProjectBudgetLineItemHelper.budgetLineItem.costSharingAmount') }

  # Rates
  value(:rate_amounts) { |b|
    array = []
    b.noko_rates_table.trs.each do |tr|
      array << {
          class: tr[0].text,
          type: tr[1].text,
          rate_cost: tr[2].text,
          rate_cost_sharing: tr[3].text
      }
    end
    array
  }

  p_element(:apply) { |rate_class, type, b| b.rates_table.trs.find{ |tr| tr[0].text==rate_class && tr[1].text==type }.checkbox }

  private

  element(:modal_div) { |b| b.div(data_parent: 'PropBudget-NonPersonnelCostsPage-EditNonPersonnel-Dialog') }
  element(:tab_list) { |b| b.modal_div.ul }
  value(:noko_rates_table) { |b| b.no_frame_noko.div(data_parent: 'PropBudget-NonPersonnelCostsPage-EditNonPersonnel-Dialog').tbody }
  element(:rates_table) { |b| b.modal_div.tbody }

end