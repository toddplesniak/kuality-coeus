class CommitteeScheduleObject < DataFactory

  include DateFactory
  include StringFactory

  attr_reader :document_id, :date, :start_time, :meridian,
              :place, :recurrence, :recurrence_settings, :status,
              :deadline, :day_of_week

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        date:               next_monday[:date_w_slashes],
        start_time:         "#{rand(12)+1}:#{rand(60)}",
        meridian:           %w{AM PM}.sample,
        place:              random_alphanums_plus(20),
        recurrence:         random_recurrence,
    }
    set_options(defaults.merge(opts))
    requires :document_id
    @recurrence_settings ||= default_recurrence_parameters[@recurrence.to_sym]
  end

  def create
    on CommitteeSchedule do |page|
      fill_out page, :date, :start_time, :place
      page.meridian @meridian
      page.recurrence @recurrence
      case @recurrence
        when 'Daily'
          page.send(@recurrence_settings[:option])
          page.day_count.fit @recurrence_settings[:count]
        when 'Weekly'
          page.week_count.fit @recurrence_settings[:count]
          @recurrence_settings[:days].each { |day| page.weekday(day) }
        when 'Monthly'
          page.send(@recurrence_settings[:option])
          page.day_of_month.fit @recurrence_settings[:day_of_month]
          page.month_count.fit @recurrence_settings[:count]
          page.weekday_month_count.fit @recurrence_settings[:count]
          page.cardinal_day.fit @recurrence_settings[:cardinal_day]
          page.day_of_week.fit @recurrence_settings[:weekday]
        when 'Yearly'
          page.send(@recurrence_settings[:option])
          page.month_w_date.fit @recurrence_settings[:month]
          page.month_w_weekday.fit @recurrence_settings[:month]
          page.day_in_month.fit @recurrence_settings[:day]
          page.cardinal_day.fit @recurrence_settings[:cardinal_day]
          page.day_of_week.fit @recurrence_settings[:weekday]
          page.simple_year_count.fit @recurrence_settings[:count]
          page.complex_year_count.fit @recurrence_settings[:count]
      end
      page.ending_on.fit @recurrence_settings[:end_on] unless @recurrence_settings.nil?
      page.add_event
      page.save
    end
  end

  # =========
  private
  # =========

  def default_recurrence_parameters
    {
        Daily:   {option: :every_x_days, count: rand(6)+1, end_on: date_factory(Time.now+(86400*(rand(365)+1)))[:date_w_slashes] },
        Weekly:  {count: rand(5)+1, days: random_weekdays, end_on: date_factory(Time.now+(86400*365*(rand(2)+1)))[:date_w_slashes] },
        Monthly: {option: :x_weekday_of_x_months, cardinal_day: random_cardinal_day, weekday: random_weekday, count: rand(12)+1, end_on: date_factory(Time.now+(86400*365*(rand(5)+1)))[:date_w_slashes] },
        Yearly:  {option: :weekday_of_month_of_x_years, cardinal_day: random_cardinal_day, weekday: random_weekday, month: random_month, count: rand(5)+1, end_on: date_factory(Time.now+(86400*365*(rand(25)+1)))[:date_w_slashes] }
    }
  end

  def random_weekdays
    %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}.shuffle.pop(rand(5))
  end

  def random_weekday
    %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}.sample
  end

  def random_cardinal_day
    %w{first second third fourth last}.sample
  end

  def random_month
    %w{JANUARY FEBRUARY MARCH APRIL MAY JUNE JULY AUGUST SEPTEMBER OCTOBER NOVEMBER DECEMBER}.sample
  end

  def random_recurrence
    %w{Never Daily Weekly Monthly Yearly}.sample
  end

end # CommitteeScheduleObject

class CommitteeScheduleCollection < CollectionsFactory

  contains CommitteeScheduleObject

end