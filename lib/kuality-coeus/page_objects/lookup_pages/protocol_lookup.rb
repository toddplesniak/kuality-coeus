class ProtocolLookup < Lookups

  expected_element :protocol_number

  url_info 'Protocols', 'kra.irb.Protocol'

  old_ui
  undefine :edit_item

  action(:edit_item) { |match, b| b.frm.link(title: b.noko_results.row(text: /#{Regexp.escape(match)}/m).link(text: 'edit').title).click; b.use_new_tab; b.close_parents }

  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolNumber') }

  element(:active_yes) { |b| b.frm.radio(name: 'active', value: 'Y') }
  element(:active_no) { |b| b.frm.radio(name: 'active', value: 'N') }
  element(:active_both) { |b| b.frm.radio(name: 'active', title: "Active - Both") }
end