class ProtocolActions < KCProtocol

  # Available Actions
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionQualifierTypeCode') }
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.scheduleId') }

  action(:protocol_actions_tab) { |b| b.frm.button(value: 'Protocol Actions').click}

  element(:expedited_review_checklist) { |b| b.frm.tr(id: 'expeditedReviewCheckList') }
  p_element(:expedited_checklist) { |i, b| b.expedited_review_checklist.checkbox(name: "actionHelper.protocolSubmitAction.expeditedReviewCheckList[#{i}].checked") }

  element(:exempt_studies_checklist) { |b| b.frm.tr(id: 'exemptStudiesCheckList') }

  action(:submit_for_review_submit) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }

  #Expedited Approval
  element(:expedited_approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.approvalDate') }
  element(:expedited_expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.expirationDate') }

  value(:expedited_approval_date_locked_value) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').td(text: /Approval Date:$/).parent.td(index: 1).text }
  value(:expedited_expiration_date_locked_value) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').td(text: /Expiration Date:$/).parent.td(index: 1).text }

  action(:submit_expedited_approval) { |b| b.frm.button(name: /^methodToCall.grantExpeditedApproval/).click }

  value(:expedited_approval_date_uneditable) { |date_slashes, b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tbody.td.tr(:index, 1)[1].text }
  value(:expedited_expiration_date_uneditable) { |date_slashes, b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tbody.td.tr(:index, 2)[1].text }

  #Create Amendment
  element(:amendment_summary) { |b| b.frm.textarea(name: 'actionHelper.protocolAmendmentBean.summary') }
  p_element(:amend) { |title, b| b.frm.checkbox(title: "#{title}") }
  # 'General Info', 'Funding Source', 'Protocol References and Other Identifiers', 'Protocol Organizations',
  # 'Subjects', 'Questionnaire', 'General Info', 'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'
  # NOTE: 'General Info' is the title for Add/Modify Notes & Attachments
  action(:create_amendment) { |b| b.frm.button(name: 'methodToCall.createAmendment.anchor:CreateAmendment').click }


  #Assign Reviewers
  element(:submit_assign_reviewers_button) { |b| b.frm.button(name: 'methodToCall.assignReviewers.anchor:AssignReviewers') }
  action(:submit_assign_reviewers) { |b| b.submit_assign_reviewers_button.click }

  #Notify Committee
  element(:committee_id_assign) { |b| b.frm.select(name: 'actionHelper.protocolNotifyCommitteeBean.committeeId') }
  element(:committee_comment) { |b| b.frm.textarea(id: 'actionHelper.protocolNotifyCommitteeBean.comment') }
  element(:committee_action_date) { |b| b.frm.text_field(id: 'actionHelper.protocolNotifyCommitteeBean.actionDate') }
  action(:submit_notify_committee) { |b| b.frm.button(name: 'methodToCall.notifyCommitteeProtocol.anchor:NotifyCommittee').click }

  #Expire
  element(:expire_action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpireBean.actionDate') }
  value(:expire_action_date_value) { |b| b.expire_action_date.value }

  # Returns an array containing the names of the listed reviewers
  value(:reviewers) { |b| b.reviewers_row.hiddens(name: /fullName/).map{|r| r.value} }
  p_element(:reviewer_type) { |name, b| b.reviewers_row.td(text: /#{name}/).parent.select(name: /actionHelper.protocolSubmitAction.reviewer\[\d+\].reviewerTypeCode/) }
  element(:reviewers_row) { |b| b.frm.tr(id: 'reviewers') }

  #Return to PI
  element(:return_to_pi_action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolReturnToPIBean.actionDate') }
  action(:submit_return_to_pi) { |b| b.frm.button(name: /^methodToCall.returnToPI.anchor/).click }


end