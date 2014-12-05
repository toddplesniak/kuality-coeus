class ActionList < BasePage

  expected_element :filter_button
  
  search_results_table

  p_value(:action_requested) { |item_id, b| b.item_row(item_id).tds[b.action_requested_column].text }
  p_value(:route_status) { |item_id, b| b.item_row(item_id).tds[b.route_status_column].text }
  element(:preferences) { |b| b.frm.button(name: 'methodToCall.viewPreferences').click; b.loading }
  element(:filter_button) { |b| b.frm.button(name: 'methodToCall.viewFilter') }
  action(:filter) { |b| b.filter_button.click; b.loading }
  action(:take_actions) { |b| b.frm.link(id: 'takeMassActions').click; b.loading }
  p_element(:action) { |item_id, b| b.item_row(item_id).select(name: /actionTakenCd/) }
  action(:outbox) { |b| b.frm.link(href: /viewOutbox/).click }
  element(:last_button) { |b| b.frm.link(text: 'Last') }
  action(:last) { |b| b.last_button.click }
  action(:refresh) { |b| b.frm.button(name: 'methodToCall.refresh').click; b.loading }

  #Default action select list for FYIs
  action(:default_action) { |b| b.frm.select(name: 'defaultActionToTake') }
  action(:apply_default_action) { |b| b.frm.link(align: 'absmiddle').click }

  # Protocol Review
  p_action(:open_review) { |match, b| b.item_row(match).link.click }

  private

  value(:action_requested_column) { |b| b.results_table.tr(index: 0).ths.find_index{|th| th.text=='Action Requested'} }
  value(:route_status_column) { |b| b.results_table.tr(index: 0).ths.find_index{|th| th.text=='Route Status'} }

end