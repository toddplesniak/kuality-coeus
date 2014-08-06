class SponsorTermLookup < Lookups

  results_multi_select

  expected_element :sponsor_term_id

  element(:last_button) { |b| b.frm.link(text: 'Last') }
  action(:last) { |b| b.last_button.click }

  element(:sponsor_term_id) { |b| b.frm.text_field(name: 'sponsorTermId') }
  element(:code) { |b| b.frm.text_field(name: 'sponsorTermCode') }
  element(:sponsor_term_type_code) { |b| b.frm.select(name: 'sponsorTermTypeCode') }
  element(:description) { |b| b.frm.text_field(name: 'description') }


  element(:sponsor_term_id_column) { |b| b.frm.link(text: 'Sponsor Term Id')}
  action(:sort_sponsor_term_id) { |b| b.sponsor_term_id_column.click }

  p_element(:select_checkbox) {|sponsor_term_it, b| b.frm.checkbox(title: "return valueSponsor Term Id=#{sponsor_term_it} ") }


end