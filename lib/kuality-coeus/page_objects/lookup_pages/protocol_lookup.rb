class ProtocolLookup < Lookups

  expected_element :protocol_number

  url_info 'Protocols', 'kra.irb.Protocol'

  old_ui

  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolNumber') }

end