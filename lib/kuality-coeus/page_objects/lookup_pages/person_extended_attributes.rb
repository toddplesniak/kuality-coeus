class PersonExtendedAttributesLookup < Lookups

  expected_element :person_id

  url_info 'Person%20Extended%20Attributes','kra.bo.KcPersonExtendedAttributes'

  element(:person_id) { |b| b.frm.text_field(name: 'personId') }

end