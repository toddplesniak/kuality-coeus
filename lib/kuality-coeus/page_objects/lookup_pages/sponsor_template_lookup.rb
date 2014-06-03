class SponsorTemplateLookup < Lookups

  expected_element :sponsor_term_type_code

  element(:sponsor_term_type_code) { |b| b.frm.select(name: 'sponsorTermTypeCode') }

end