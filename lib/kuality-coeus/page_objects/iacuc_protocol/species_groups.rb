class SpeciesGroups < KCProtocol

  element(:species_group_field) { |b| b.frm.text_field(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesGroup') }
  element(:species) { |b| b.frm.select(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesCode') }
  element(:pain_category) { |b| b.frm.select(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.painCategoryCode') }
  element(:count_type) { |b| b.frm.select(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesCountCode') }
  element(:species_count) { |b| b.frm.text_field(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesCount') }

  action(:add_species) { |b| b.frm.button(name: 'methodToCall.addProtocolSpecies.anchorSpeciesGroups').click; b.loading}

  #After adding a group
  p_element(:species_group_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesGroup") }
  p_element(:species_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}]") }
  p_element(:pain_category_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].painCategoryCode") }
  p_element(:count_type_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCountCode") }
  p_element(:species_count_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCount") }
  p_action(:delete_species) { |index, b| b.frm.button(name: "methodToCall.deleteProtocolSpecies.line#{index}.anchor0.validate0").click }

end
