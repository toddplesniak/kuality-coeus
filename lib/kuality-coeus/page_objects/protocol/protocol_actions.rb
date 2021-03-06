class ProtocolActions < KCProtocol

  # Available Actions
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionQualifierTypeCode') }
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.scheduleId') }

  # Returns an array containing the names of the listed reviewers
  value(:reviewers) { |b| b.reviewers_row.hiddens(name: /fullName/).map{|r| r.value} }

  p_element(:reviewer_type) { |name, b| b.reviewers_row.td(text: /#{name}/).parent.select(name: /actionHelper.protocolSubmitAction.reviewer\[\d+\].reviewerTypeCode/) }

  element(:reviewers_row) { |b| b.frm.tr(id: 'reviewers') }
  element(:expedited_review_checklist) { |b| b.frm.tr(id: 'expeditedReviewCheckList') }
  element(:exempt_studies_checklist) { |b| b.frm.tr(id: 'exemptStudiesCheckList') }

  action(:submit_for_review) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }

end