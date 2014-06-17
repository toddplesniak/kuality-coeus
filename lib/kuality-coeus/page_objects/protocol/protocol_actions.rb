class ProtocolActions < KCProtocol

  # Available Actions
  # Submit for Review
  element(:submit_for_review_div) { |b| b.frm.div(id: 'tab-:SubmitforReview-div') }
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionQualifierTypeCode') }
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.scheduleId') }

  # Returns an array containing the names of the listed reviewers
  value(:reviewers) { |b|
                       # Note that this method works for both Submit for Review...
                       if b.submit_for_review_div.present?
                         b.reviewers_row.hiddens(name: /fullName/).map{|r| r.value}
                       else
                       # ...or for Assign Reviewers
                         b.assign_reviewers_div.selects(title: 'Reviewer Type').map{|s| s.parent.parent.td.text}
                       end
  }

  p_element(:reviewer_type) { |name, b| b.reviewers_container.td(text: /#{name}/).parent.select(name: /reviewerTypeCode/) }

  element(:reviewers_row) { |b| b.frm.tr(id: 'reviewers') }
  element(:expedited_review_checklist) { |b| b.frm.tr(id: 'expeditedReviewCheckList') }
  element(:exempt_studies_checklist) { |b| b.frm.tr(id: 'exemptStudiesCheckList') }

  action(:submit_for_review) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }

  # Assign Reviewers
  element(:assign_reviewers_div) { |b| b.frm.div(id: 'tab-:AssignReviewers-div') }

  private

  element(:reviewers_container) { |b|
    if b.reviewers_row.present?
      reviewers_row
    else
      assign_reviewers_div
    end
  }

end