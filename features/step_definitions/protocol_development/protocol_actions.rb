And /assigns the Protocol to an agenda$/ do
  @irb_protocol.assign_to_agenda
end

And /records the Committee's approval decision for the Protocol/ do
  @irb_protocol.view 'Protocol Actions'
  on RecordCommitteeDecision do |page|
    page.expand_all
    page.motion_type.fit 'Approve'
    page.yes_count.set @committee.members.size
    page.submit
  end

  DEBUG.message @irb_protocol.protocol_number

end