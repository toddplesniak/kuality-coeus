class IACUCProtocolOverview < KCProtocol

  #removed the method created in the KCProtocol, because
  # of medusa method in search_results_table
  undefine :medusa

  description_field
  tiny_buttons

  #DEBUG: These are commented out until I can
  # fix merge problems with Todd...
  #search_results_table
  #protocol_common

  # Required Fields
  element(:protocol_project_type) { |b| b.frm.select(name: 'document.protocolList[0].protocolProjectTypeCode') }
  element(:lay_statement_1) { |b| b.frm.textarea(name: 'document.protocolList[0].layStatement1') }
  element(:lay_statement_2) { |b| b.frm.textarea(name: 'document.protocolList[0].layStatement2') }
end
