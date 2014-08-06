class SponsorTermLookup < Lookups

  results_multi_select

  expected_element :sponsor_term_id

  element(:last_button) { |b| b.frm.link(text: 'Last') }
  action(:last) { |b| b.last_button.click }

  element(:sponsor_term_id) { |b| b.frm.text_field(name: 'sponsorTermId') }
  element(:code) { |b| b.frm.text_field(name: 'sponsorTermCode') }
  element(:sponsor_term_type_code) { |b| b.frm.select(name: 'sponsorTermTypeCode') }
  element(:description) { |b| b.frm.text_field(name: 'description') }

  # SEARCH RESULTS TABLE
  element(:sponsor_term_id_column) { |b| b.frm.link(text: 'Sponsor Term Id')}
  action(:sort_sponsor_term_id) { |b| b.sponsor_term_id_column.click }

  #For search results this column on the table is called 'Select?'
  p_element(:select_checkbox) {|sponsor_term_id, b| b.frm.checkbox(title: "return valueSponsor Term Id=#{sponsor_term_id} ") }

  p_element(:sponsor_term_type_code_line) { |code, b| b.frm.link(title: "Sponsor Term Type Sponsor Term Type Code=#{code} ") }

end