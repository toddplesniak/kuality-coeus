class Members < CommitteeDocument

  action(:employee_search) { |b| b.frm.image(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:committeeHelper.newCommitteeMembership.personId,fullName:committeeHelper.newCommitteeMembership.personName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:non_employee_search) { |b| b.frm.image(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.NonOrganizationalRolodex!!).(((rolodexId:committeeHelper.newCommitteeMembership.rolodexId,fullName:committeeHelper.newCommitteeMembership.personName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:clear) { |b| b.frm.image(name: 'methodToCall.clearCommitteeMembership').click }
  action(:add_member) { |b| b.frm.image(name: 'methodToCall.addCommitteeMembership').click }

  # This is used to grab the name of the person being added BEFORE the "add member" button
  # is clicked.


end