Then /^the IACUC Protocol status should be (.*)$/ do |status|
  on IACUCProtocolOverview do |page|
    page.document_status.should == status
  end
end

Then /^the summary will display the location of the procedure$/ do
  on IACUCProcedures do |page|
    page.procedure_tab('summary')
    page.expand_all

    page.summary_locations.should include @iacuc_protocol.location[:type]
    page.summary_locations.should include @iacuc_protocol.location[:name]
    page.summary_locations.should include @iacuc_protocol.location[:room].to_s
    page.summary_locations.should include @iacuc_protocol.location[:description]
  end
end