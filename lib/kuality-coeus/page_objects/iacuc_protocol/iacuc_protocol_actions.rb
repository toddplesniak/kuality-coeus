class IACUCProtocolActions < KCProtocol

end

class AdminApproveProtocol < KCProtocol
  undefine :expiration_date
  element(:approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.approvalDate') }
  element(:expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.expirationDate') }
  element(:comments) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminApprovalBean.actionDate') }

  element(:approve_div) { |b| b.frm.div(id: 'tab-:AdministrativelyApproveProtocol-div') }
  action(:submit) { |b| b.approve_div.button(name: /^methodToCall.grantAdminApproval.anchor/).click; b.loading; b.awaiting_doc }
end

class AdminIncompleteProtocol < KCProtocol
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.protocolAdminIncompleteBean.reason') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolAdminIncompleteBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.administrativelyMarkIncompleteProtocol.anchor:AdministrativelyMarkIncompleteProtocol').click; b.loading; b.awaiting_doc }
end

class ManageReviewAttachments < KCProtocol
  element(:description) { |b| b.frm.textarea(name: 'actionHelper.protocolManageReviewCommentsBean.reviewAttachmentsBean.newReviewAttachment.description') }
  element(:file_name) { |b| b.frm.fiile_field(name: 'actionHelper.protocolManageReviewCommentsBean.reviewAttachmentsBean.newReviewAttachment.newFile') }
  element(:can_view) { |b| b.frm.checkbox(name: 'actionHelper.protocolManageReviewCommentsBean.reviewAttachmentsBean.newReviewAttachment.protocolPersonCanView') }
  action(:add_attachment) { |b| b.frm.button(name: /^methodToCall.addReviewAttachment.taskNameprotocolManageReviewComments.anchor/).click; b.loading }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.manageAttachments.anchor/).click; b.loading }
end

class IACUCSubmitForReview < KCProtocol
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolSubmitAction.submissionTypeCode') }
  element(:review_type) { |b| b.frm.select(name: 'actionHelper.iacucProtocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.iacucProtocolSubmitAction.submissionQualifierTypeCode') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }
end

class RequestToDeactivate < KCProtocol
  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolDeactivateRequestBean.reason') }
  action(:submit_button) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameiacucProtocolRequestDeactivate.anchor:RequesttoDeactivate') }
  action(:submit) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameiacucProtocolRequestDeactivate.anchor:RequesttoDeactivate').click; b.loading}
  action(:submit2_button) { |b| b.frm.button(name: /^methodToCall.iacucDeactivate.anchor/) }
  action(:submit2) { |b| b.frm.button(name: /^methodToCall.iacucDeactivate.anchor/).click; b.loading }

end

class PlaceHold < KCProtocol
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolHoldBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.iacucProtocolHoldBean.actionDate') }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.iacucHold.anchor/).click; b.loading }
end

class LiftHold < KCProtocol
  element(:comments) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolLiftHoldBean.comments') }
  element(:action_date) { |b| b.frm.text_field(name: 'actionHelper.iacucProtocolLiftHoldBean.actionDate') }
  element(:submit) { |b| b.frm.button(name: /^methodToCall.iacucLiftHold.anchor/).click; b.loading }
end