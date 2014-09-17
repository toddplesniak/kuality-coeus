And /adds a Species group to the IACUC Protocol$/ do
  @iacuc_protocol.add_species_group
end

And /assigns a location to the Procedure with a type of '(.*)' on the IACUC Protocol$/ do |type|
  @iacuc_protocol.procedures.set_location(type: type, room: '101', description: random_alphanums_plus, species: @iacuc_protocol.species[:species])
end

And /adds a Procedure to the IACUC Protocol$/ do
  @iacuc_protocol.add_procedure
end

When /sends a deactivate request on the IACUC Protocol$/ do
   @iacuc_protocol.request_to_deactivate
end

And   /places the IACUC Protocol on hold$/ do
  @iacuc_protocol.place_hold
end

When  /lifts the hold on the IACUC Protocol$/ do
  @iacuc_protocol.lift_hold
end

When /^the IACUC Administrator approves the IACUC Protocol$/ do
  steps '* log in with the IACUC Administrator user'
  @iacuc_protocol.admin_approve
end

When /adds an organization to the IACUC Protocol$/ do
  @iacuc_protocol.add_organization
end

When /attempts to add an organization to the IACUC Protocol without required fields$/ do
  @iacuc_protocol.add_organization organization_id: nil, organization_type: nil
  @errors = [
      'Organization Id is a required field.',
      'Organization Type is a required field.'
  ]
end

And /changes the contact information on the added Organization$/ do
  #clear contact based off of the org id
  @iacuc_protocol.clear_contact(@iacuc_protocol.organization[:organization_id])
  #select a new address from the search
  @iacuc_protocol.add_contact_info(@iacuc_protocol.organization[:organization_id])
end

When  /reopens the IACUC Protocol without saving changes$/ do
  on(IACUCProtocolOverview).close
  on(Confirmation).no
  @iacuc_protocol.view_document
end