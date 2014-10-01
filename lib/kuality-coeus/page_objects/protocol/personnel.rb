class ProtocolPersonnel < KCProtocol

  element(:protocol_role) { |b| b.frm.select(name: 'personnelHelper.newProtocolPerson.protocolPersonRoleId') }
  action(:employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:personnelHelper.newProtocolPerson.personId,fullName:personnelHelper.newProtocolPerson.personName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:non_employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.NonOrganizationalRolodex!!).(((rolodexId:personnelHelper.newProtocolPerson.rolodexId,fullName:personnelHelper.newProtocolPerson.personName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:add_person) { |b| b.frm.button(name: 'methodToCall.addProtocolPerson').click; b.loading }

  #added people
  p_element(:added_personnel_name) { |full_name, role, b| b.frm.div(id: 'workarea').table(text: "#{full_name}" + ' ' + "#{role}") }

end