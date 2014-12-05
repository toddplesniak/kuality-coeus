class Rates < BudgetDocument

  buttons 'Sync All Rates', 'Refresh All Rates'
  links 'Research F & A', 'Fringe Benefits', 'Inflation', 'Vacation', 'Lab Allocation - Salaries', 'Lab Allocation - Other', 'Other'

  p_element(:applicable_rate) { |desc, on_camp, f_yr, b| b.visible_table.tr(text: /^#{desc}.+#{on_camp}.+#{f_yr}/m).text_field(name: /applicableRate$/) }

  private

  element(:visible_table) { |b| b.tables(class: 'table table-condensed table-bordered uif-tableCollectionLayout dataTable').find { |table| table.visible? } }

end