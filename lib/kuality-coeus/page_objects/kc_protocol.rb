class KCProtocol < BasePage

  document_header_elements
  tab_buttons
  global_buttons
  error_messages

  buttons 'Protocol', 'Personnel', 'Questionnaire', 'Custom Data', 'Special Review',
          'Permissions', 'Notes & Attachments', 'Protocol Actions', 'Medusa', 'Online Review'

  # This removes the methods created in the BasePage, because
  # the Protocol child classes need their own specialized versions...
  undefine :submit, :committee_id

end