class IACUCProcedures < KCProtocol

  #Tabs
  element(:procedures_tab_div) { |b| b.frm.div(id: 'tab-ProcedureDetails-div') }
  p_action(:select_procedure_tab) { |tab, b| b.procedures_tab_div.button(value: tab).click; b.loading }

  #Procedures
  #Checkboxes. no tags
  element(:procedures_table) { |b| b.frm.table(id: 'included-categories-table') }
  p_element(:category) { |index, b| b.procedures_table.tr.checkbox(name: "iacucProtocolProceduresHelper.allProcedures[#{index}].procedureSelected") }

  p_element(:select_species) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupBeans[#{index}].protocolSpeciesAndGroups") }
  p_action(:add_species) { |index, b| b.frm.button(name: /^methodToCall.addProtocolStudyGroup.line#{index}.anchor/).click; b.loading }

  #Personnel
  p_action(:edit_procedures) { |person_number='1', b| b.frm.th(text: "#{person_number}").parent.link(id: 'editProcedureLink').click }

  #modal
  element(:all_procedures) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').checkbox(class: 'checkBoxSelectAll') }
  element(:all_group) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').checkbox(class: 'checkBoxAllGroup') }
  action(:save_procedure) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').button(id: 'onProcedureEdit').click; b.loading }

  p_element(:qualifications) { |list_index='0', person_index='0', b| b.frm.textarea(name: "document.protocolList[#{list_index}].protocolPersons[#{person_index}].procedureQualificationDescription") }

  #Location
  element(:location_type) { |b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationTypeCode') }
  element(:location_name) { |b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationId') }
  element(:location_room) { |b| b.frm.text_field(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationRoom') }
  element(:location_description) { |b| b.frm.textarea(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.studyGroupLocationDescription') }

  p_action(:add_location) { |index_list=0, b| b.frm.button(name: "methodToCall.addProcedureLocation.document.protocolList[#{index_list}].iacucProtocolStudyGroupBeans[].iacucProtocolStudyGroupDetailBeans[].line").click; b.loading }

  element(:location_table) { |b| b.frm.table(id: 'procedureLocationsTableId') }
  action(:location_edit_procedures) { |b| b.frm.link(id: 'editProcedureLink').click }

  #Summary
  value(:summary_custom_data) { |b| b.frm.div(align: 'left', index: 1).text }
  value(:summary_personnel) { |b| b.frm.div(align: 'left', index: 2).text }
  value(:summary_locations) { |b| b.frm.div(align: 'left', index: 3).text }


end