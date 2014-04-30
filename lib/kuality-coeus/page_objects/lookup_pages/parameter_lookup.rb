class ParameterLookup < Lookups

  element(:parameter_name) { |b| b.frm.text_field(id: 'name') }

end