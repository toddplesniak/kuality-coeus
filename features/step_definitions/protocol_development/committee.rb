And /the IRB Admin submits a Committee with events scheduled before and after its adv submission days setting/ do
  steps '* log in with the IRB Administrator user'
  @committee = create CommitteeDocumentObject
  @committee.add_schedule recurrence: 'Daily', date: date_factory(Time.now+(86400*(@committee.adv_submission_days.to_i-7)))[:date_w_slashes],
                          recurrence_settings: {option: :every_x_days,
                                                count: 1,
                                                end_on: date_factory(Time.now+(86400*(@committee.adv_submission_days.to_i)))[:date_w_slashes] }
  @committee.submit
end

Then /the earliest available schedule date is based on the Committee's Adv Submission Days value/ do
  on(ProtocolActions).schedule_date.options[1].text[/^\d+-\d+-\d+/].should==(Time.now+(86400*(@committee.adv_submission_days.to_i))).strftime('%m-%d-%Y')
end

And /the IRB Admin submits a Committee that allows a maximum of 1 protocol/ do
  steps '* log in with the IRB Administrator user'
  @committee = create CommitteeDocumentObject, maximum_protocols: '1'
  @committee.submit
end