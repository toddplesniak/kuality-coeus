And /adds a species group to the IACUC Protocol$/ do
  @iacuc_protocol.add_species_group
end

And /assigns a procedure to the personnel for location Performance Site$/ do
  @iacuc_protocol.add_procedure
  @iacuc_protocol.set_location(type: 'Performance Site')
end
