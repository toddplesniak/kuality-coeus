Then /^the IACUC Protocol status should be (.*)$/ do |status|
  on IACUCProtocolOverview do |page|
        expect(page.document_status).to eq status
  end
end

Then /^the IACUC Protocol submission status should be (.*)$/ do |status|
  on IACUCProtocolOverview do |page|
    expect(page.submission_status).to eq status
  end
end

Then /^the summary will display the location of the procedure$/ do
  on IACUCProcedures do |page|
    page.select_procedure_tab 'summary'
    page.expand_all

    expect(page.summary_locations).to include @iacuc_protocol.procedures.location[:type]
    expect(page.summary_locations).to include @iacuc_protocol.procedures.location[:description]
    expect(page.summary_locations).to include @iacuc_protocol.procedures.location[:room].to_s
    expect(page.summary_locations).to include @iacuc_protocol.procedures.location[:name]
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