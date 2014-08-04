class AssignToAgenda < KCProtocol

  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.assignToAgendaBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.assignToAgendaBean.actionDate') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.assignToAgenda.anchor38').click; b.loading }

end