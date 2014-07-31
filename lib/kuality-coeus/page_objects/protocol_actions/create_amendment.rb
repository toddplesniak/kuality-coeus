class CreateAmendment < KCProtocol

  element(:amendment_summary) { |b| b.frm.textarea(name: 'actionHelper.protocolAmendmentBean.summary') }

  # Valid parameter values for the #amend method include the following strings:
  # 'General Info', 'Funding Source', 'Protocol References and Other Identifiers', 'Protocol Organizations',
  # 'Subjects', 'Questionnaire', 'General Info', 'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'
  #
  # NOTE: 'General Info' is the title for Add/Modify Notes & Attachments
  p_element(:amend) { |title, b| b.frm.checkbox(title: "#{title}") }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.createAmendment.anchor:CreateAmendment').click }

end