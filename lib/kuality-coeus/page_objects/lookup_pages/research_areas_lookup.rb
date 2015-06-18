class ResearchAreasLookup < Lookups

  old_ui

  expected_element :research_area_code

  results_multi_select

  undefine :check_item

  p_action(:check_item) { |description, b| b.frm.table(id: 'row').td(class: 'infocell', title: description).parent.checkbox.set }

  element(:research_area_code) { |b| b.frm.text_field(name: 'researchAreaCode') }
  element(:parent_research_area_code) { |b| b.frm.text_field(name: 'parentResearchAreaCode') }
  element(:code_description) { |b| b.frm.text_field(name: 'description') }

  value(:research_descriptions) { |b| b.noko.table(id: 'row').rows.map{ |row| row.tds[4].title }[2..-1] }

end
