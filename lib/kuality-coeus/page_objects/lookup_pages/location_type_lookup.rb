class LocationTypeLookup < Lookups

  expected_element :location_type_code

  element(:location_type_code) { |b| b.frm.text_field(name: 'locationTypeCode') }
  element(:location_type) { |b| b.frm.text_field(name: 'location') }

end