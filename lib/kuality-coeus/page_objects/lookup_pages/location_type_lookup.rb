class LocationTypeLookup < Lookups

  expected_element :location_type_code

  old_ui

  element(:location_type_code) { |b| b.frm.text_field(name: 'locationTypeCode') }
  element(:location_type) { |b| b.frm.text_field(name: 'location') }

  value(:result_table_text) { |b| b.frm.tbody.text}
  action(:delete_location) { |name_code, b| b.frm.link(title: "delete Location Type withLocation Type Code=#{name_code} ").click }

end