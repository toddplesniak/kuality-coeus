class SponsorTemplateLookup < Lookups

  results_multi_select


  expected_element :sponsor_term_type_code

  element(:sponsor_term_type_code) { |b| b.frm.select(name: 'sponsorTermTypeCode') }

  p_element(:select_checkbox) {|sponsor_term_it, b| b.frm.checkbox(title: "return valueSponsor Term Id=#{sponsor_term_it} ") }

end