class NonPersonnelCosts < BasePage

  action(:assign_non_personnel) { |b| b.button(text: 'Assign Non-Personnel...').click; b.loading }

  p_action(:details_of) { |description, b| b.items_rows.find{ |item| item[0].text==description }.button().click; b.loading }


  private

  element(:items_rows) { |b| b.active_tab.tbody.trs.find_all{ |tr| tr.id==''} }
  element(:active_tab) { |b| b.div(class: 'tab-pane active') }

end