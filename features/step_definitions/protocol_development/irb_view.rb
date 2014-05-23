Then /^the (.*) Checklist can be filled out$/ do |checklist|
  on(ProtocolActions).send("#{damballa(checklist)}_checklist".to_sym).should be_present
end