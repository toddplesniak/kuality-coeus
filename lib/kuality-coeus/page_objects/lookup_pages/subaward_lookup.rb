class SubawardLookup < Lookups

  element(:subaward_id) { |b| b.frm.text_field(name: 'subAwardCode') }
  
end
