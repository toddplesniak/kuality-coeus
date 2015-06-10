class ModularBudget < BasePage

  p_action(:view_period) { |number, b| b.link(text: /Period #{number}/).click }

  element(:direct_cost_less_cons_fa) { |b| b.text_field(title: 'Direct Cost Less Consortium FNA') }
  element(:consortium_f_and_a) { |b| b.text_field(title: 'Consortium FNA') }
  
  element(:f_and_a_rate_type) { |b| b.select(name: 'newBudgetModularIdc.description') }
  element(:f_and_a_rate) { |b| b.text_field(name: 'newBudgetModularIdc.idcRate') }
  element(:f_and_a_base) { |b| b.text_field(name: 'newBudgetModularIdc.idcBase') }
  action(:add_f_and_a) { |b| b.button(name: 'methodToCall.add').click; b.loading }

  action(:sync) { |b| b.button(text: 'Sync').click; b.loading }

end