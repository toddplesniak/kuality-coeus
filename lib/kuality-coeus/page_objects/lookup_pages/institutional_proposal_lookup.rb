class InstitutionalProposalLookup < Lookups

  expected_element :institutional_proposal_number

  url_info 'Search%20Institutional%20Proposals','kra.institutionalproposal.home.InstitutionalProposal'
  old_ui

  STATUS = 4

  element(:institutional_proposal_number) { |b| b.frm.text_field(name: 'proposalNumber') }
  element(:institutional_proposal_status) { |b| b.frm.select(name: 'statusCode') }
  element(:account_id) { |b| b.frm.text_field(name: 'currentAccountNumber') }
  element(:sponsor_id) { |b| b.frm.text_field(name: 'sponsorCode') }
  element(:sponsor_name) { |b| b.frm.text_field(name: 'sponsor.sponsorName') }
  p_value(:ip_status) { |match, p| p.item_row(match)[STATUS].text }

  # This returns an array containing whatever institutional proposal
  # numbers were returned in the search...
  value(:institutional_proposal_numbers) { |b| b.target_column(2).map{ |td| td.text } }

end