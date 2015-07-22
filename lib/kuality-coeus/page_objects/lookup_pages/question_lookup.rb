class QuestionLookup < Lookups

  old_ui

  element(:question_id) { |b| b.frm.text_field(id: 'questionSeqId') }
  element(:question) { |b| b.frm.text_field(id: 'question') }

  value(:target_question_id) { |b| b.noko.tds(class: 'infocell')[1].text }

end