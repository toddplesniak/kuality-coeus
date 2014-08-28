When /(IACUC Protocol Creator |)creates an? IACUC Protocol$/ do |role_name|
  case role_name
    when 'IACUC Protocol Creator '
      steps '* I log in with the IACUC Protocol Creator user'
    else
      pending "Need to handle the #{role_name} for log in with this step"
  end
  @iacuc_protocol = create IACUCProtocolObject
end


When /^the IACUC Protocol Creator attempts to create an IACUC Protocol but misses a required field$/ do
  steps %{ * I log in with the IACUC Protocol Creator user }
  # Pick a field at random for the test...
  required_field = ['Description', 'Lay Statement 1', 'Lead Unit', 'Title'
  ].sample
  field = damballa(required_field)
  @iacuc_protocol = create IACUCProtocolObject, field=>' ', alternate_search_required: nil
  text = ' is a required field.'
  errors = {
      description: "Document Description (Description)#{text}",
      lay_statement_1: "Lay Statement 1 (Lay Statement 1)#{text}",
      lead_unit: "#{required_field} (#{required_field})#{text}",
      title: "Title (Title)#{text}"
  }
  @required_field_error = errors[field]
end


And /the IACUC Administrator creates an? IACUC Committee with an? area of research/ do
  steps '* log in with the IACUC Administrator user'
  @committee = create CommitteeDocumentObject, committee_type: 'iacuc', review_type: 'Full Committee Member Review'
  @committee.add_area_of_research

end


And /(IACUC Protocol Creator | )creates an IACUC Protocol with one species group$$/ do |role_name|
  case role_name
    when 'IACUC Protocol Creator '
      steps '* I log in with the IACUC Protocol Creator user'
    else
      pending "Need to handle the #{role_name} for log in with this step"
  end
  @iacuc_protocol = create IACUCProtocolObject

  @iacuc_protocol.add_species_group
end