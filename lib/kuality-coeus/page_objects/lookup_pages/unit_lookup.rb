class UnitLookup < Lookups

  old_ui

  url_info 'Unit','kra.bo.Unit'

  element(:page_links) { |b| b.frm.span(class: 'pagelinks').links }

end