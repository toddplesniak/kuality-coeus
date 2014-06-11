class ProposalSummary < ProposalDevelopmentDocument

  expected_element :proposal_summary_div

  element(:proposal_summary_div) { |b| b.frm.div(id: 'tab-ProposalSummary-div') }
  
  element(:disapprove_button) { |b| b.frm.button(name: 'methodToCall.disapprove') }
  element(:reject_button) { |b| b.frm.button(name: 'methodToCall.reject') }

end