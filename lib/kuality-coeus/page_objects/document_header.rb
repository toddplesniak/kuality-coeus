class DocumentHeader < BasePage

  expected_element(:headerarea, 3)

  element(:headerarea) { |b| b.frm.div(id: 'headerarea') }

  document_header_elements

end