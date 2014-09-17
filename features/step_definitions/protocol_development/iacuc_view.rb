Then /^the IACUC Protocol status should be (.*)$/ do |status|
  on IACUCProtocolOverview do |page|
        page.document_status.should == status
  end
end

Then /^the IACUC Protocol submission status should be (.*)$/ do |status|
  on IACUCProtocolOverview do |page|
    page.submission_status.should == status
  end
end

Then /^the summary will display the location of the procedure$/ do
  on IACUCProcedures do |page|
    page.procedure_tab('summary')
    page.expand_all

    page.summary_locations.should include @iacuc_protocol.procedures.location[:type]
    page.summary_locations.should include @iacuc_protocol.procedures.location[:description]
    page.summary_locations.should include @iacuc_protocol.procedures.location[:room].to_s
    page.summary_locations.should include @iacuc_protocol.procedures.location[:name]
  end
end

Then /^the expiration date is set for the Protocol$/ do
  on(KCProtocol).expiration_date.should_not == ''
  on(KCProtocol).expiration_date.should_not == nil
end

Then /^the added Organization should be displayed on the IACUC Protocol$/ do
  on IACUCProtocolOverview do |page|
    page.added_organization_id_with_name(1).should include @iacuc_protocol.organization[:organization_id]
  end
end

And /^the id should be on the Organization inquiry page$/ do
  on(IACUCProtocolOverview).direct_inquiry(@iacuc_protocol.organization[:organization_id])
  on OrganizationDetail do |page|
    page.organization_id.should == @iacuc_protocol.organization[:organization_id]
  end
end

Then /^on the IACUC Protocol the contact information for the added Organization is reverted$/ do
  @iacuc_protocol.view_document
  on IACUCProtocolOverview do |page|
    page.expand_all
    page.contact_address(@iacuc_protocol.organization[:organization_id]).should == @iacuc_protocol.old_organization_address
  end
end