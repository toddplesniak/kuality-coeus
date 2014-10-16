Then /^the IACUC Protocol status should be (.*)$/ do |status|
  on IACUCProtocolOverview do |page|
    expect(page.document_status).to eq status
  end
end

Then /^the IACUC Protocol submission status should be (.*)$/ do |submission_status|
    @iacuc_protocol.view 'Protocol'
    #Need to collect page info because amendment has different fields from the default.
    @iacuc_protocol.gather_document_info
    expect(@iacuc_protocol.doc[:submission_status]).to eq submission_status
end

Then /^the summary will display the location of the procedure$/ do
  on IACUCProcedures do |page|
    page.select_procedure_tab 'summary'
    page.expand_all

    expect(page.summary_locations).to include @procedures.location[:type]
    expect(page.summary_locations).to include @procedures.location[:description]
    expect(page.summary_locations).to include @procedures.location[:room].to_s
    expect(page.summary_locations).to include @procedures.location[:name]
  end
end

Then /^the expiration date is set for the Protocol$/ do
  expect(on(KCProtocol).expiration_date).to_not equal ''
  expect(on(KCProtocol).expiration_date).to_not equal nil
end

Then /the ?(.*) Organization that was added should display on the IACUC Protocol$/ do |count|
  on IACUCProtocolOverview do |page|
    index = { '' => 1, 'first' => 1, 'second' => 2 }
    expect(page.added_organization_id_with_name(index[count])).to include @iacuc_protocol.organization.organization_id
  end
end

And /^the added Organization information should display on the inquiry page$/ do
  on(IACUCProtocolOverview).direct_inquiry(@iacuc_protocol.organization.organization_id)
  on OrganizationInquiry do |page|
    expect(page.organization_id).to eq @iacuc_protocol.organization.organization_id
    expect(page.address).to eq @iacuc_protocol.organization.organization_address
    expect(page.organization_name).to eq @iacuc_protocol.organization.organization_name
  end
end

Then /^on the IACUC Protocol the contact information for the added Organization is reverted$/ do
  @iacuc_protocol.view_document
  on IACUCProtocolOverview do |page|
    page.expand_all
    expect(page.contact_address(@iacuc_protocol.organization.organization_id)).to eq @iacuc_protocol.organization.old_organization_address
  end
end

Then /^the group name, species, pain category, count type, species count should match the (.*) values$/ do |count|
  index = {'modified' => 0}
    on SpeciesGroups do |page|
      expect(page.group_added_value(index[count])).to eq @species.group
      expect(page.count_added_value(index[count])).to eq @species.count.to_s
      expect(page.species_added_value(index[count])).to eq @species.species
      expect(page.pain_category_added_value(index[count])).to eq @species.pain_category
      expect(page.count_type_added_value(index[count])).to eq @species.count_type
    end
end

Then /^the (.*) Species added should be the only Species on the IACUC Protocol$/ do |count|
  on SpeciesGroups do |page|
    index = {'second' => 0}
    if count == 'second'
      expect(page.group_added(index[count]).value).to_not eq @species.group
      expect(page.group_added(index[count]).value).to eq @species2.group
    else
      pending "Need to handle validation for #{count} Species"
    end
  end
end

Then /^both personnel added to the IACUC Protocol are present$/ do
  on ProtocolPersonnel do |page|
    expect(page.added_personnel_name(@personnel.full_name, @personnel.protocol_role)).to exist
    expect(page.added_personnel_name(@personnel2.full_name, @personnel2.protocol_role)).to exist
  end
end

Then /^the three principles should have the edited values after saving the IACUC Protocol$/ do
  on TheThreeRs do |page|
    page.save
    page.refresh
    on(IACUCProtocolOverview).description.wait_until_present
    @iacuc_protocol.view "The Three R's"

    expect(page.reduction.value).to eq @iacuc_protocol.principles[:reduction]
    expect(page.refinement.value).to eq @iacuc_protocol.principles[:refinement]
    expect(page.replacement.value).to eq @iacuc_protocol.principles[:replacement]
    page.save

    page.reduction_expand
    page.continue_button.wait_until_present
    expect(page.reduction.value).to eq @iacuc_protocol.principles[:reduction]
    page.continue

    page.refinement_expand
    page.continue_button.wait_until_present
    expect(page.refinement.value).to eq @iacuc_protocol.principles[:refinement]
    page.continue

    page.replacement_expand
    page.continue_button.wait_until_present
    expect(page.replacement.value).to eq @iacuc_protocol.principles[:replacement]
    page.continue
  end
end

Then /(first |)Special Review should be displayed on the IACUC Protocol$/ do |count|
  index = { 'first ' => 0 }

  on SpecialReview do |page|
    page.reload
    on(Confirmation).yes if on(Confirmation).yes_button.present?

    expect(page.type_added(index[count]).selected_options.first.text).to eq @special_review.type
    expect(page.approval_status_added(index[count]).selected_options.first.text).to eq @special_review.approval_status
  end
end