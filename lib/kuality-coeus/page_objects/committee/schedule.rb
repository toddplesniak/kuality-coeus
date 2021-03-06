class CommitteeSchedule < CommitteeDocument
  
  element(:date) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.scheduleStartDate') }
  element(:start_time) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.time.time') }
  p_element(:meridian) { |m, b| b.frm.radio(value: m).set }
  element(:place) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.place') }

  p_action(:recurrence) { |recur, b| b.frm.radio(value: recur.upcase).set }

  # Daily
  element(:every_x_days) { |b| b.day_option('XDAY') }
  element(:every_weekday) { |b| b.day_option('WEEKDAY') }
  element(:day_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.dailySchedule.day') }

  # Weekly
  element(:week_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.weeklySchedule.week') }
  p_action(:weekday) { |weekday, b| b.frm.checkbox(name: 'committeeHelper.scheduleData.weeklySchedule.daysOfWeek', value: weekday).set }

  # Monthly
  element(:day_x_of_x_months) { |b| b.month_option('XDAYANDXMONTH') }
  element(:x_weekday_of_x_months) { |b| b.month_option('XDAYOFWEEKANDXMONTH') }
  element(:day_of_month) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.monthlySchedule.day') }
  element(:month_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.monthlySchedule.option1Month') }
  element(:weekday_month_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.monthlySchedule.option2Month') }

  # Yearly
  element(:date_of_x_years) { |b| b.year_option('XDAY') }
  element(:weekday_of_month_of_x_years) { |b| b.year_option('CMPLX') }
  element(:month_w_date) { |b| b.frm.select(name: 'committeeHelper.scheduleData.yearlySchedule.selectedOption1Month') }
  element(:day_in_month) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.yearlySchedule.day') }
  element(:simple_year_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.yearlySchedule.option1Year') }
  element(:month_w_weekday) { |b| b.frm.select(name: 'committeeHelper.scheduleData.yearlySchedule.selectedOption2Month') }
  element(:complex_year_count) { |b| b.frm.text_field(name: 'committeeHelper.scheduleData.yearlySchedule.option2Year') }

  # Common...
  element(:ending_on) { |b| b.frm.text_fields(name: /scheduleEndDate/).find{ |field| field.present? } }
  element(:cardinal_day) { |b| b.frm.selects(name: /selectedMonthsWeek/).find{ |field| field.present? } }
  element(:day_of_week) { |b| b.frm.selects(name: /selectedDayOfWeek/).find{ |field| field.present? } }

  action(:add_event) { |b| b.frm.button(name: 'methodToCall.addEvent.anchorSchedule').click }

  # Event list

  private
  # Acceptable parameter values: 'XDAY' or 'WEEKDAY'
  p_action(:day_option) { |type, b| b.frm.radio(name: 'committeeHelper.scheduleData.dailySchedule.dayOption', value: type).set }
  # Acceptable parameter values are: 'XDAYANDXMONTH' or 'XDAYOFWEEKANDXMONTH'
  p_action(:month_option) { |option, b| b.frm.radio(name: 'committeeHelper.scheduleData.monthlySchedule.monthOption', value: option).set }
  # Acceptable parameter values are: 'XDAY' or 'CMPLX'
  p_action(:year_option) { |option, b| b.frm.radio(name: 'committeeHelper.scheduleData.yearlySchedule.yearOption', value: option).set }


end