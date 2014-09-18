class RequestToDeactivate < KCProtocol

  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolDeactivateRequestBean.reason') }
  action(:submit_button) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameiacucProtocolRequestDeactivate.anchor:RequesttoDeactivate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameiacucProtocolRequestDeactivate.anchor:RequesttoDeactivate').click; b.loading}
  action(:submit2_button) { |b| b.frm.button(name: /^methodToCall.iacucDeactivate.anchor/) }
  action(:submit2) { |b| b.frm.button(name: /^methodToCall.iacucDeactivate.anchor/).click; b.loading }

end