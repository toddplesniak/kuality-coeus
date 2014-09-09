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