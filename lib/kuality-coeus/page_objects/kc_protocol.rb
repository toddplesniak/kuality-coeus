class KCProtocol < BasePage

  document_header_elements
  tab_buttons
  global_buttons
  error_messages

  buttons 'Protocol', 'Personnel', 'Questionnaire', 'Custom Data', 'Special Review',
          'Permissions', 'Notes & Attachments', 'Protocol Actions', 'Medusa', 'Online Review'

  value(:current_tab_is) { |b| b.frm.dt(class: 'licurrent').button.value}

end