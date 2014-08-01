class ReturnToPI < KCProtocol

  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolReturnToPIBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.returnToPI.anchor/).click; b.loading; b.awaiting_doc }

end