And /adds a Species group to the IACUC Protocol$/ do
  @species = create SpeciesObject
end

And /assigns a location to the Procedure with a type of '(.*)' on the IACUC Protocol$/ do |type|
  @procedures.set_location(type: type, room: rand(100..999), description: random_alphanums_plus, species: @species.species)
end

And /adds a Procedure to the IACUC Protocol$/ do
  @procedures = create IACUCProceduresObject
end

When /deactivates the IACUC Protocol$/ do
   @iacuc_protocol.request_to_deactivate
end

And   /places the IACUC Protocol on hold$/ do
  @iacuc_protocol.place_hold
end

When  /lifts the hold placed on the IACUC Protocol$/ do
  @iacuc_protocol.lift_hold
end

When /^the IACUC Administrator approves the IACUC Protocol$/ do
  steps '* log in with the IACUC Administrator user'
  @iacuc_protocol.admin_approve
end

When /adds an organization to the IACUC Protocol$/ do
  @iacuc_protocol.add_organization
end

When /attempts to add an organization to the IACUC Protocol without the required fields$/ do
  @iacuc_protocol.add_organization organization_id: nil, organization_type: nil, press: nil
  @errors = [
      'Organization Id is a required field.',
      'Organization Type is a required field.'
  ]
end

And /changes the contact information on the added Organization$/ do
  #clear contact based off of the org id
  @iacuc_protocol.organization.clear_contact(@iacuc_protocol.organization.organization_id)
  #select a new address from the search
  @iacuc_protocol.organization.add_contact_info(@iacuc_protocol.organization.organization_id)
end

When  /reopens the IACUC Protocol without saving the changes$/ do
  on(IACUCProtocolOverview).close
  on(Confirmation).no
  @iacuc_protocol.view_document
end

When /attempts to add a Species with non-integers as the species count$/ do
  #error message only displays 8 characters
  @species = create SpeciesObject, count: random_alphanums(8)

  DEBUG.message "#{@species.count} is the species count"
  # @iacuc_protocol.add_species count: random_alphanums(8)
  @errors = [
      "#{@species.count} is not a valid integer."
  ]
end

When /saves the IACUC Protocol after modifying the required fields for the Species$/ do
  @species.edit press: 'save', index: 0,
                group: random_alphanums_plus(10, 'Species '),
                species: '::random::',
                pain_category: '::random::',
                count_type: '::random::',
                count: rand(1..21),
                strain: random_alphanums_plus,
                usda_covered: :set,
                procedure_summary: random_alphanums_plus(20)
end

When /^the IACUC Protocol Creator deletes the (.*) Species$/ do |line_item|
  index = {'first' => 0, 'second' => 1}
  on SpeciesGroups do |page|
    page.delete(index[line_item])
  end
  on(Confirmation).yes
end

When /adds (.*) personnel members? to the IACUC Protocol$/ do |num|
  count = {'one' => 1, 'two' => 2}
  @personnel = create IACUCPersonnel
  @personnel2 = create IACUCPersonnel if count[num] > 1
end