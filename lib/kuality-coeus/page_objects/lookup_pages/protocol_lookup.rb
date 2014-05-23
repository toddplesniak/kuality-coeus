class ProtocolLookup < Lookups

  url_info 'Protocols', 'kra.irb.Protocol'

  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolNumber') }

end