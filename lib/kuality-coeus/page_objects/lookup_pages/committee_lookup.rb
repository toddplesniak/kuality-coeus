class CommitteeLookup < Lookups
  
  url_info 'Committee', 'kra.committee.bo.Committee'
  
  element(:committee_id) { |b| b.frm.text_field(name: 'committeeId') }
  
end