class ModifySubmissionRequest < KCProtocol
  
  element(:committee) { |b| b.frm.select(name: 'actionHelper.assignCmtSchedBean.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.assignCmtSchedBean.scheduleId') }
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.protocolModifySubmissionBean.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolModifySubmissionBean.protocolReviewTypeCode') }
  element(:billable) { |b| b.frm.checkbox(name: 'actionHelper.protocolModifySubmissionBean.billable') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolModifySubmissionBean.submissionQualifierTypeCode') }

  action(:submit) { |b| b.frm.button(name: 'methodToCall.modifySubmissionAction.anchor:ModifySubmissionRequest').click; b.loading }
  
end