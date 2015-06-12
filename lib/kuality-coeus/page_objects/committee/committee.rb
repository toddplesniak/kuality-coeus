class Committee < CommitteeDocument

  expected_element :workarea_div

  document_header_elements
  description_field

  undefine :submit
  action(:submit) { |b| b.frm.button(title: 'submit').when_present.click; b.loading_old; b.awaiting_doc }

  element(:committee_id_field) { |b| b.frm.text_field(id: 'document.committeeList[0].committeeId') }
  element(:committee_name_field) { |b| b.frm.text_field(id: 'document.committeeList[0].committeeName') }
  element(:home_unit) { |b| b.frm.text_field(id: 'document.committeeList[0].homeUnitNumber') }
  element(:min_members_for_quorum) { |b| b.frm.text_field(id: 'document.committeeList[0].minimumMembersRequired') }
  element(:maximum_protocols) { |b| b.frm.text_field(id: 'document.committeeList[0].maxProtocols') }
  element(:adv_submission_days) { |b| b.frm.text_field(id: 'document.committeeList[0].advancedSubmissionDaysRequired') }
  element(:review_type) { |b| b.frm.select(id: 'document.committeeList[0].reviewTypeCode') }
  value(:updated_user) { |p| p.com_table.row(text: /Updated User:/).cell(index: -1).text }

  action(:area_of_research) { |b| b.frm.div(id: 'researchAreaDiv').button(name: 'methodToCall.performLookup.(!!org.kuali.kra.iacuc.IacucResearchArea!!).((``)).(:;committeeResearchAreas;:).((%true%)).((~~)).anchorAreaofResearch').click }

  private

  element(:com_table) { |b| b.frm.div(id: 'tab-Committee-div').table }

end