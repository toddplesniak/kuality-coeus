Then /^the (.*) Checklist can be filled out$/ do |checklist|
  on(ProtocolActions).send("#{damballa(checklist)}_checklist".to_sym).should be_present
end

Then /the system warns that the number of protocols exceeds the allowed maximum/ do
  on(Confirmation).message.should=='The number of Protocols has reached or exceeded the maximum. Do you still want to submit the Protocol?'
end