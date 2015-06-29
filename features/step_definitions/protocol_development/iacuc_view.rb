Then /^the IACUC Protocol (submission status|status) should be (.*)$/ do |status_field, status_message|
    @iacuc_protocol.view 'Protocol'
    expect(on(IACUCProtocolOverview).send(damballa(status_field))).to eq status_message
end

Then /^the summary will display the location of the procedure$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:type, :room, :name, :description].each { |field| expect(page.locations).to include @iacuc_protocol.procedures.locations[0].send(field) }
  end
end

Then /^the edited location information should be displayed in the Procedure summary$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  [:room, :name, :description].each { |field|
    expect(on(IACUCProceduresSummary).locations).to include @iacuc_protocol.procedures.locations[0].send(field)
  }
end

Then /^the (first |second )location is not listed in the Procedure summary$/ do |count|
  location = {'first ' => 0, 'second ' => 1}
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:room, :name, :description].each { |field| expect(page.locations).to_not include @iacuc_protocol.procedures.locations[location[count]].send(field) }
  end
end

And /^the (first |second )location is listed on the IACUC Protocol$/ do |count|
  procedure = {'first ' => 0, 'second ' => 1}
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:type, :room, :name, :description].each { |field| expect(page.locations).to include @iacuc_protocol.procedures.locations[procedure[count]].send(field) }
  end
end

Then /^the expiration date is set for the Protocol$/ do
  expect(on(KCProtocol).expiration_date).to_not equal ''
  expect(on(KCProtocol).expiration_date).to_not equal nil
end

Then /^the (.*)Organization that was added should display on the IACUC Protocol$/ do |count|
  index = { '' => 0, 'first ' => 0, 'second ' => 1 }
  on IACUCProtocolOverview do |page|



    DEBUG.pause 5757



    expect(page.added_organization_id_with_name(index[count])).to include @iacuc_protocol.organizations[index[count]].organization_id
  end
end

And /^the added Organization information should display on the inquiry page$/ do
  on(IACUCProtocolOverview).direct_inquiry(@iacuc_protocol.organizations[0].organization_id)
  on OrganizationInquiry do |page|
    expect(page.organization_id).to eq @iacuc_protocol.organizations[0].organization_id
    expect(page.address).to eq @iacuc_protocol.organizations[0].organization_address
    expect(page.organization_name).to eq @iacuc_protocol.organizations[0].organization_name
  end
end

Then /^on the IACUC Protocol the contact information for the added Organization is reverted$/ do
  on IACUCProtocolOverview do |page|
    page.expand_all
    expect(page.contact_address(@iacuc_protocol.organizations[0].organization_id)).to eq @iacuc_protocol.organizations[0].old_organization_address
  end
end

Then /^the group name, species, pain category, count type, species count should match the modified values$/ do
  line_item = 0
  on SpeciesGroups do |page|
    expect(page.group_added_value(line_item)).to eq @species.group
    expect(page.count_added_value(line_item)).to eq @species.count.to_s
    expect(page.species_added_value(line_item)).to eq @species.species
    expect(page.pain_category_added_value(line_item)).to eq @species.pain_category
    expect(page.count_type_added_value(line_item)).to eq @species.count_type
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

Then /^the personnel members? added to the IACUC Protocol (is|are) present$/ do |x|
  on ProtocolPersonnel do |page|
    @iacuc_protocol.personnel.each do |person|
      expect(page.added_people).to include person.full_name
    end
  end
end

Then /^the three principles should have the edited values after saving the IACUC Protocol$/ do
  on TheThreeRs do |page|
    page.save
    page.refresh
    on(IACUCProtocolOverview).description.wait_until_present
    @iacuc_protocol.view "The Three R's"
    principle = ['reduction', 'refinement', 'replacement']
    principle.each {|prince| expect(page.send(prince).value).to eq @iacuc_protocol.principles[prince.to_sym] }
    page.save

    principle.each do |prince|
      page.send("#{prince}_expand")
      page.continue_button.wait_until_present
      expect(page.send(prince).value).to eq @iacuc_protocol.principles[prince.to_sym]
      page.continue
    end
  end
end

Then /(first |second |)Special Review should (not |)be updated on the IACUC Protocol$/ do |count, to_be_or_not_to_be|
  index = {'' => 0, 'first ' => 0, 'second ' => 1 }
  on SpecialReview do |page|
    page.reload
    confirmation
    if to_be_or_not_to_be == 'not '
      expect(page.type_added(index[count]).selected_options.first.text).to_not eq @iacuc_protocol.special_review[index[count]].type
      expect(page.approval_status_added(index[count]).selected_options.first.text).to_not eq @iacuc_protocol.special_review[index[count]].approval_status
    else
      expect(page.type_added(index[count]).selected_options.first.text).to eq @iacuc_protocol.special_review[index[count]].type
      expect(page.approval_status_added(index[count]).selected_options.first.text).to eq @iacuc_protocol.special_review[index[count]].approval_status
    end
  end
end

# ----
# Procedures Tab
# ----

#assusmes we are already on the Procedures tab
And /reloads? the IACUC Protocol to the procedures summary tab$/ do
  on(IACUCProcedures).reload
  on(Confirmation).yes if on(Confirmation).yes_button.present?
  on(IACUCProcedures).select_procedure_tab 'summary'
  on(IACUCProceduresSummary).expand_all
end

Then /^the procedures summary will display qualifications for the personnel$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.view_qualification(@iacuc_protocol.procedures.personnel[0].full_name)
    expect(page.qualification_dialog).to include @iacuc_protocol.procedures.personnel[0].qualifications
  end
end