class TheThreeRs < KCProtocol

  element(:reduction) {|b| b.frm.textarea(name: 'document.protocolList[0].iacucPrinciples[0].reduction') }
  element(:refinement) {|b| b.frm.textarea(name: 'document.protocolList[0].iacucPrinciples[0].refinement') }
  element(:replacement) {|b| b.frm.textarea(name: 'document.protocolList[0].iacucPrinciples[0].replacement') }

  element(:alternate_search_required) { |b| b.frm.select(name: 'document.protocolList[0].iacucPrinciples[0].searchRequired') }

end
