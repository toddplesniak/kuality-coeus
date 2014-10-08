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

When /edits the Principles of (.*)/ do |principle|
  on TheThreeRs do |page|
    case principle
      when 'reduction'
        page.reduction.fit @iacuc_protocol.principles[:reduction]
      when 'refinement'
        page.refinement.fit @iacuc_protocol.principles[:refinement]
      when 'replacement'
        page.replacement.fit @iacuc_protocol.principles[:replacement]
    end
  end
end

When /attempts to add a Special Review to generate error messages$/ do
  @special_review = create  SpecialReviewObject, type: nil, approval_status: nil,
                            application_date: rand(130000..999999), approval_date: rand(130000..999999),
                            expiration_date: rand(130000..999999),
                            press: nil
  @errors = [
      'Type is a required field.',
      'Approval Status is a required field.',
      "#{@special_review.application_date} is not a valid date.",
      "#{@special_review.approval_date} is not a valid date.",
      "#{@special_review.expiration_date} is not a valid date.",
  ]
end

When /attempts to add a Special Review for human subjects, status approved, and an exemption$/ do

  @special_review = create  SpecialReviewObject, type: 'Human Subjects', approval_status: 'Approved',
                            exemption_number: '::random::',
                            press: nil
  @errors = [
      'Protocol Number is a required field for Human Subjects/Approved.',
      'Cannot select Exemption # for Human Subjects/Approved',
  ]
end

When /attempts to add a Special Review to generate error messages for incorrect date structures$/ do
  @special_review = create  SpecialReviewObject, application_date: tomorrow[:date_w_slashes], approval_date: right_now[:date_w_slashes],
                            expiration_date: yesterday[:date_w_slashes], exemption_number: '::random::',
                            press: nil
  @errors = [
      'Approval Date should be the same or later than Application Date.',
      'Expiration Date should be the same or later than Approval Date.',
      'Expiration Date should be the same or later than Application Date.'
  ]
end

When /adds a Special Review to the IACUC Protocol$/ do
  @special_review = create SpecialReviewObject
end