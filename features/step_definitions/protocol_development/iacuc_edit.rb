And /adds a species group to the IACUC Protocol$/ do
  @iacuc_protocol.add_species_group
end

And /assigns a procedure to the personnel for location Performance Site$/ do
  @iacuc_protocol.add_procedure

  @iacuc_protocol.set_location(type: 'Performance Site')
end

When /sends a deactivate request on the IACUC Protocol$/ do
   @iacuc_protocol.request_to_deactivate
end

And   /places the IACUC Protocol on hold$/ do
  @iacuc_protocol.place_hold
end

When  /lifts the hold on the IACUC Protocol$/ do
  @iacuc_protocol.lift_hold
end