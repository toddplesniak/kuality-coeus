class CommitteeLookup < Lookups

  url_info 'Committee%20Lookup','kra.committee.bo.Committee'

  element(:committee_id) { |b| b.frm.text_field(name: 'committeeId') }
  
end