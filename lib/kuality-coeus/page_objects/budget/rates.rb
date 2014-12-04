class Rates < BudgetDocument

  buttons 'Sync All Rates', 'Refresh All Rates'

  p_element(:applicable_rate) { |desc, on_camp, f_yr, b| b.frm.tr(/^#{desc}.#{on_camp}.#{f_yr}/m).text_field(name: /applicableRate$/) }
  
end