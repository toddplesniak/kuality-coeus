class Committee < CommitteeDocument

  expected_element :workarea_div

  document_header_elements
  description_field

  element(:committee_id_field) { |b| b.frm.text_field(id: 'document.committeeList[0].committeeId') }
  element(:committee_name_field) { |b| b.frm.text_field(id: 'document.committeeList[0].committeeName') }
  element(:home_unit) { |b| b.frm.text_field(id: 'document.committeeList[0].homeUnitNumber') }
  element(:min_members_for_quorum) { |b| b.frm.text_field(id: 'document.committeeList[0].minimumMembersRequired') }
  element(:maximum_protocols) { |b| b.frm.text_field(id: 'document.committeeList[0].maxProtocols') }
  element(:adv_submission_days) { |b| b.frm.text_field(id: 'document.committeeList[0].advancedSubmissionDaysRequired') }
  element(:review_type) { |b| b.frm.select(id: 'document.committeeList[0].reviewTypeCode') }
  #value(:last_updated) { |p| p.com_table.row(text: /Last Updated:/).cell(index: -1).text }
  value(:updated_user) { |p| p.com_table.row(text: /Updated User:/).cell(index: -1).text }

  element(:area_of_research_div) { |b| b.frm.div(id: 'researchAreaDiv') }
  action(:area_of_research) { |b| b.area_of_research_div.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.iacuc.IacucResearchArea!!).((``)).(:;committeeResearchAreas;:).((%true%)).((~~)).anchorAreaofResearch').click }

  private

  element(:com_table) { |b| b.frm.div(id: 'tab-Committee-div').table }

end