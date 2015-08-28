class KCAwards < BasePage

  tab_buttons
  global_buttons
  error_messages

  buttons_frame 'Award', 'Contacts', 'Commitments', 'Budget Versions',
          'Payment, Reports & Terms', 'Special Review', 'Custom Data',
          'Comments, Notes & Attachments', 'Award Actions', 'Medusa'

  value(:current_tab) {|b| b.frm.span(class: 'tabright tabcurrent').button.value }
  value(:doc_title) { |b| b.noko.div(id: 'headerarea').h1.text.strip }
  action(:time_and_money) { |b| b.t_m_button.when_present.click; b.loading }
  element(:t_m_button) { |b| b.frm.button(name: 'methodToCall.timeAndMoney') }
  element(:horzontal_links) { |b| b.div(id: 'horz-links') }
  element(:headerinfo_table) { |b| b.noko.div(class: 'headerbox').table(class: 'headerinfo') }
  # The 'header' prefix on these method names is to prevent collision...
  value(:header_pi) { |b| b.headerinfo_table[0][1].text }
  value(:header_lead_unit) { |b| b.headerinfo_table[1][1].text }
  value(:header_sponsor_name) { |b| b.headerinfo_table[2][1].text }
  value(:header_document_id) { |b| b.headerinfo_table[0][3].text[/\d+/] }
  value(:header_status) { |b| b.headerinfo_table[0][3].text[/(?<=:).*/] }
  value(:header_award_id) { |b| b.headerinfo_table[1][3].text[/.*(?=:)/] }
  value(:header_account) { |b| b.headerinfo_table[1][3].text[/(?<=:).*/] }
  value(:header_last_update) { |b| b.headerinfo_table[2][3].text }

  class << self

    def terms *terms
      terms.each_with_index do |term, index|
        name=damballa(term)
        tag=term.gsub(/([\s\/])/,'')
        element("#{name}_code".to_sym) { |b| b.frm.text_field(name: "sponsorTermFormHelper.newSponsorTerms[#{index}].sponsorTermCode") }
        action("add_#{name}_term") { |b| b.frm.button(name: /addAwardSponsorTerm.+anchorAwardTerms:#{tag}Terms/).click; b.loading }
        action("search_#{name}_term") { |b|b.frm.button(name: /methodToCall.performLookup.+anchorAwardTerms:#{term.gsub(' ','')}/).click; b.loading }
      end
    end
    
  end

end