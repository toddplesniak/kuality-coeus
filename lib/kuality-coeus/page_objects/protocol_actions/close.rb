class Close < KCProtocol

  element(:comments) { |b| b.frm.text_area(name: 'actionHelper.protocolCloseBean.comments') }

end