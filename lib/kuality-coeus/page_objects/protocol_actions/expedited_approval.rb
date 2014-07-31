class ExpeditedApproval < KCProtocol

  undefine :expiration_date

  element(:approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.approvalDate') }
  element(:expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.expirationDate') }

  # TODO: roll these into the above methods...
  value(:approval_date_ro) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tr.th(text: /Approval Date:$/).parent.td.text }
  value(:expiration_date_ro) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tr.th(text: /Expiration Date:$/).parent.td.text }

  action(:submit) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').button(name: /^methodToCall.grantExpeditedApproval/).click; b.loading; b.awaiting_doc }

end