class Questionnaire < BasePage

  description_field
  tab_buttons

  action(:add_question) { |b| b.frm.button(name: 'rootSearch').click; b.use_new_tab }

end