class ProtocolActions < KCProtocol

  # Available Actions
  # Submit for Review
  element(:submit_for_review_div) { |b| b.frm.div(id: 'tab-:SubmitforReview-div') }
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionQualifierTypeCode') }
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.scheduleId') }

  element(:expedited_review_checklist) { |b| b.frm.tr(id: 'expeditedReviewCheckList') }
  p_element(:expedited_checklist) { |i, b| b.expedited_review_checklist.checkbox(name: "actionHelper.protocolSubmitAction.expeditedReviewCheckList[#{i}].checked") }

  element(:exempt_studies_checklist) { |b| b.frm.tr(id: 'exemptStudiesCheckList') }

  action(:submit_for_review_submit) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }

  #Expedited Approval
  element(:expedited_approval_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.approvalDate') }
  element(:expedited_expiration_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpeditedApprovalBean.expirationDate') }

  value(:expedited_approval_date_locked_value) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tr.th(text: /Approval Date:$/).parent.td.text }
  value(:expedited_expiration_date_locked_value) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').tr.th(text: /Expiration Date:$/).parent.td.text }

  action(:submit_expedited_approval) { |b| b.frm.div(id: 'tab-:ExpeditedApproval-div').button(name: /^methodToCall.grantExpeditedApproval/).click }

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
  action(:submit_notify_committee) { |b| b.frm.div(id: 'tab-:NotifyCommittee-div').button(name: 'methodToCall.notifyCommitteeProtocol.anchor:NotifyCommittee').click }

  #Expire
  element(:expire_action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolExpireBean.actionDate') }
  value(:expire_action_date_value) { |b| b.expire_action_date.value }

  # Returns an array containing the names of the listed reviewers
  value(:reviewers) { |b|
                       # Note that this method works for both Submit for Review...
                       if b.reviewers_row.present?
                         b.reviewers_row.hiddens(name: /fullName/).map{|r| r.value}
                       else
                       # ...or for Assign Reviewers
                         b.assign_reviewers_div.selects(title: 'Reviewer Type').map{|s| s.parent.parent.td.text}
                       end
  }

  p_element(:reviewer_type) { |name, b| b.reviewers_container.td(text: name ).parent.select(name: /reviewerTypeCode/) }

  element(:reviewers_row) { |b| b.frm.tr(id: 'reviewers') }

  #Return to PI
  element(:return_to_pi_action_date) { |b| b.frm.text_field(name: 'actionHelper.protocolReturnToPIBean.actionDate') }
  action(:submit_return_to_pi) { |b| b.frm.button(name: /^methodToCall.returnToPI.anchor/).click }

  # Assign Reviewers
  element(:assign_reviewers_div) { |b| b.frm.div(id: 'tab-:AssignReviewers-div') }
  action(:assign_reviewers) { |b| b.frm.button(name:'methodToCall.assignReviewers.anchor:AssignReviewers').click; b.loading }

  # Manage Review Comments
  p_element(:review_comment) { |text, b| b.frm.textarea(value: text) }
  p_element(:comment_private) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Private') }
  p_element(:comment_final) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Final') }
  action(:manage_comments) { |b| b.frm.button(name: /methodToCall.manageComments.anchor/).click; b.loading }

  # Withdraw Protocol
  element(:withdrawal_reason) { |b| b.frm.textarea(name: 'actionHelper.protocolWithdrawBean.reason') }
  action(:submit_withdrawal_reason) { |b| b.frm.button(name: 'methodToCall.withdrawProtocol.anchor:WithdrawProtocol').click; b.loading }

  # Summary & History
  value(:review_comments) { |b|
    begin
      b.review_comments_table.hiddens.map{ |hid| hid.value }
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      []
    end
  }

  private

  element(:reviewers_container) { |b|
    if b.reviewers_row.present?
      b.reviewers_row
    else
      b.assign_reviewers_div
    end
  }

  element(:review_comments_table) { |b| b.frm.div(id: 'tab-:ReviewComments-div').table }

  value(:summary_initial_approval_date) { |b| b.frm..div(id: 'tab-:Summary-div').th(text: 'Expiration Date:').parent.td(index: 0).text }
  value(:summary_expiration_date) { |b| b.frm..div(id: 'tab-:Summary-div').th(text: 'Expiration Date:').parent.td(index: 1).text }
end