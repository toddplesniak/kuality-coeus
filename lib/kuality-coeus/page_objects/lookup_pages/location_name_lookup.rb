class LocationNameLookup < Lookups

  old_ui

  expected_element :location_name_code

  element(:location_name_code) { |b| b.frm.text_field(name: 'locationId') }
  element(:location_name) { |b| b.frm.text_field(name: 'locationName') }

  value(:result_table_text) { |b| b.frm.tbody.text}
  action(:delete_location) { |name_code, b| b.frm.link(title: "delete Location Name withLocation Name Code=#{name_code} ").click }
end