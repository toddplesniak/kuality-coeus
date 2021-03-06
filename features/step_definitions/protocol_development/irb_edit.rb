When /^the Protocol is given an '(.*)' Submission Review Type$/ do |type|
  @irb_protocol.view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.submission_review_type.select type
  end
end

When /the Protocol is being submitted to that Committee for review/ do
  @irb_protocol.view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.committee.select @committee.name
  end
end

And /^submits the Protocol to the Committee for review$/ do
  @irb_protocol.submit_for_review committee: @committee.name
end

When /the second Protocol is submitted to the Committee for review on the same date/ do
  @irb_protocol2.submit_for_review committee: @committee.name, schedule_date: @irb_protocol.schedule_date
end