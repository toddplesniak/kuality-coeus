class CommitteeSchedule < CommitteeDocument
  
  element(:date) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.scheduleStartDate') }
  element(:start_time) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.time.time') }
  p_element(:meridian) { |m, b| b.frm.radio(value: m).set }
  element(:place) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.place') }

  p_action(:recurrence) { |recur, b| b.frm.radio(value: recur.upcase).set }

  # Daily
  p_action(:every) { |type, b| b.frm.radio(name: 'committeeHelper.scheduleData.dailySchedule.dayOption', value: type).set }
  element(:day_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.dailySchedule.day') }
  element(:daily_end_date) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.dailySchedule.scheduleEndDate') }
  
  # Weekly
  element(:week_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.weeklySchedule.week') }
  p_action(:weekday) { |weekday, b| b.frm.checkbox(name: 'committeeHelper.scheduleData.weeklySchedule.daysOfWeek', value: weekday).set }
  element(:weekly_end_date) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.weeklySchedule.scheduleEndDate') }

  # Monthly
  p_action(:month_option) { |option, b| b.frm.radio(name: 'committeeHelper.scheduleData.monthlySchedule.monthOption', value: option).set }
  element(:day_of_month) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.monthlySchedule.day') }
  element(:month_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.monthlySchedule.option1Month') }
  element(:cardinal_day) { |b| b.frm.select(name: 'committeeHelper.scheduleData.monthlySchedule.selectedMonthsWeek') }
  element(:month_weekday) { |b| b.frm.select(name: 'committeeHelper.scheduleData.monthlySchedule.selectedDayOfWeek') }

  # Yearly


  action(:add_event) { |b| b.frm.button(name: 'methodToCall.addEvent.anchorSchedule').click }

  # Event list


  
end