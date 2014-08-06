class Permissions < ProposalDevelopmentDocument

  USER_NAME = 1
  FULL_NAME = 2
  UNIT_NUM  = 3
  UNIT_NAME = 4
  ROLE      = 5

  action(:assigned_to_role) { |role, b| b.frm.td(id: role).text }

  element(:user_name) { |b| b.frm.text_field(id: 'newProposalUser.username') }
  element(:role) { |b| b.frm.select(id: 'newProposalUser.roleName') }
  action(:add) { |b| b.frm.button(name: 'methodToCall.addProposalUser.anchorUsers').click }

  action(:assigned_role) { |user, b| b.user_row(user)[ROLE].text }
  action(:edit_role) { |user, b| b.user_row(user).button(name: /methodToCall.editRoles.line\d+.anchorUsers/).click }
  action(:delete) { |user, b| b.user_row(user).button(name: /methodToCall.deleteProposalUser.line\d+.anchorUsers/).click }

  value(:assigned_users) { |b| array=[]; b.user_roles_table.rows.each{ |row| array << row[USER_NAME].text}; 2.times{array.delete_at(0)}; array }

  # Note this is the table in the Users tab on the page...
  element(:user_roles_table) { |b| b.frm.table(id: 'user-roles') }

  action(:user_row) { |user, b| b.user_roles_table.row(text: /#{Regexp.escape(user)}/) }

end

# This a child window that appears when you click the
# "edit role" button for an existing participant.
class Roles < BasePage

  error_messages

  element(:set_roles_button) { |b| b.frm.button(name: 'methodToCall.setEditRoles') }
  action(:save) { |b| b.set_roles_button.click }

  class << self

    def chkbx(name, number)
      element(name) { |b| b.frm.checkbox(name: "proposalUserEditRoles.roleStates[#{number}].state") }
    end

    def delete_number
      $base_url=~/kuali.org/ ? 9 : 7
    end

    def approver_number
      $base_url=~/kuali.org/ ? 6 : 4
    end

  end

  chkbx :viewer, 0
  chkbx :budget_creator, 1
  chkbx :narrative_writer, 2
  chkbx :aggregator, 3
  chkbx :delete_proposal, delete_number
  chkbx :approver, approver_number

end