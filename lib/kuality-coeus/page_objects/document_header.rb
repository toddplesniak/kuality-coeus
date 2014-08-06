class DocumentHeader < BasePage

  expected_element(:header_table, 10)

  document_header_elements

  element(:header_table) { |b| b.frm.table(class: 'headerinfo') }

end