class IACUCProtocolLookup < Lookups

  expected_element :protocol_number

  url_info 'Search Protocols', 'kra.iacuc.IacucProtocol'

  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolNumber') }

end