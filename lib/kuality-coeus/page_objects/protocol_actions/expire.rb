class Expire < KCProtocol

  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpireBean.actionDate') }

end