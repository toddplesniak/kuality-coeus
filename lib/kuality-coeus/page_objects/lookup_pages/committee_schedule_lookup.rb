class CommitteeScheduleLookup < Lookups

  expected_element :protocol_number

  url_info 'Schedule%20Lookup','kra.committee.bo.CommitteeSchedule'
  
  element(:protocol_number) { |b| b.frm.text_field(name: 'protocolSubmissions.protocolNumber') }

  # Use for opening the only meeting returned in the list...
  action(:open_meeting) { |b| b.results_table.td(class: 'infocell').link.click; b.use_new_tab; b.close_parents }

end