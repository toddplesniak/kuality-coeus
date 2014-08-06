class ProposalDevelopmentDocument < BasePage

  expected_element(:header_table, 3)

  document_header_elements
  tab_buttons
  global_buttons
  error_messages

  buttons 'Proposal', 'S2S', 'Key Personnel', 'Special Review', 'Custom Data',
          'Abstracts and Attachments', 'Questions', 'Budget Versions', 'Permissions',
          'Proposal Summary', 'Proposal Actions', 'Medusa'

  element(:header_table) { |b| b.frm.table(class: 'headerinfo') }

end