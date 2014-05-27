class Members < CommitteeDocument

  action(:employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:committeeHelper.newCommitteeMembership.personId,fullName:committeeHelper.newCommitteeMembership.personName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:non_employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.NonOrganizationalRolodex!!).(((rolodexId:committeeHelper.newCommitteeMembership.rolodexId,fullName:committeeHelper.newCommitteeMembership.personName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:clear) { |b| b.frm.button(name: 'methodToCall.clearCommitteeMembership').click }
  action(:add_member) { |b| b.frm.button(name: 'methodToCall.addCommitteeMembership').click }

  # This is used to grab the name of the person being added BEFORE the "add member" button
  # is clicked.
  value(:member_name_pre_add) { |b| onespace(b.frm.label.text) }

  # Member-specific fields...
  p_element(:membership_type) { |name, b| b.member_area(name).select(title: '* Membership Type') }
  p_element(:paid_member) { |name, b| b.member_area(name).checkbox }
  p_element(:term_start_date) { |name, b| b.member_area(name).text_field(title: '* Term Start Date') }
  p_element(:term_end_date) { |name, b| b.member_area(name).text_field(title: '* Term End Date') }
  p_element(:add_role_type) { |name, b| b.member_area(name).select(name: /membershipRoleCode/) }
  p_element(:add_role_start_date) { |name, b| b.member_area(name).text_field(title: '* Start Date') }
  p_element(:add_role_end_date) { |name, b| b.member_area(name).text_field(title: '* End Date') }
  p_action(:add_role) { |name, b| b.member_area(name).button(name: /methodToCall.addCommitteeMembershipRole.document.committeeList/).click }
  p_action(:lookup_expertise) { |name, b| b.member_area(name).button(alt: 'Multiple Value Search on ').click }

  private
  p_element(:member_area) { |name, b| b.frm.h3(text: /#{name}/).parent }

end