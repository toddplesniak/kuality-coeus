# This class is specifically for personnel assigned to a period. Not for persons
# who have been added to the Budget ("Project Personnel"). That is the BudgetPersonnelObject class.
class AssignedPerson < DataFactory

  include Utilities, DateFactory

  attr_reader :person, :object_code, :group, :start_date,
              :end_date, :percent_effort, :percent_charged,
              :period_type, :requested_salary
  attr_accessor :rate_details, :monthly_base_salary

  def initialize(browser, opts={})
    @browser = browser
    percent = rand(99)+1
    defaults = {
      object_code:         '::random::',
      group:               'Default',
      percent_effort:      percent.to_s,
      percent_charged:     (percent*0.8).round(2).to_s,
      period_type:         '::random::'
    }
    set_options(defaults.merge(opts))
    requires :person, :monthly_base_salary, :period_number
  end

  def create
    # Navigation to this point must be done by the parent Period object
    on AddPersonnelToPeriod do |page|
      # These three fields have been pulled out of the
      # fill_out method because of some sort of
      # low-level bug that causes Selenium to complain
      # that they are no longer in the page DOM.
      # A TODO in the future should be to test adding
      #  these fields back to the fill_out list, to
      # see if the bug has been addressed.
      page.object_code.pick! @object_code
      page.percent_effort.set @percent_effort
      page.percent_charged.set @percent_charged
      page.person.select /#{@person}/
      fill_out page, :group, :start_date, :end_date, :period_type
      @start_date ||= page.start_date.value
      @end_date ||= page.end_date.value
      page.assign_to_period
    end
    on(AssignPersonnelToPeriods).save
  end

  def requested_salary
    amounts = [0.0]
    item_months(start, end_d).each { |month|
      if month[:full]
        amounts << monthly_calculated_salary
      else
        amounts << daily_salary(month[:start_date])*month[:days]*perc_chrgd
      end
      amounts << salary_inflation(month)
    }

    DEBUG.inspect amounts

    amounts.inject(0, :+).round(2)
  end

  def cost_sharing
    ((middle_months_count*monthly_calc_cost_share) +
        start_month_calc_cost_share +
        end_mnth_calc_cost_sharing
    ).round(2)
  end

  def rate_cost(description)
    amounts = []
    @rate_details.rates.description(description).each { |rate|
      # What is the item's start date?
      start
      # What is the line item's end date?
      end_d
      # Is this date range longer than a month?
      # Yes...

      # No


      # What is the applicable rate's start date?
      rate.start_date
      # What is the rate end date?
      rate.end_date

      # Is the end of the current month before the line item end date?

      #
    }
    amounts.inject(0, :+)
  end

  def rate_cost_sharing(rate)
    (cost_sharing*(rate.to_f/100)).round(2)
  end

  def salary_inflation(month)
    rate_to_apply = inflation_rates.find { |rate|
      rate.start_date <= month[:start_date] && rate.end_date >= month[:end_date]
    }
    return 0 if rate_to_apply.nil? || rate_to_apply.start_date < start && @period_number==1
    #TODO: Rate end earlier than month end...'
    #daily_salary(rate_to_apply.end_date)*rate_to_apply.end_date.day*perc_chrgd*rate_to_apply.applicable_rate.to_f/100
    if month[:full]
      monthly_calculated_salary*rate_to_apply.applicable_rate.to_f/100
    else

      DEBUG.message 'partial month...'

      daily_salary(month[:start_date])*month[:days]*perc_chrgd*rate_to_apply.applicable_rate.to_f/100
    end
  end

  def start_month_days(date)
    days_prior = date.day-1
    days_in_month(date.year, date.month) - days_prior
  end

  def inflation_rates
    @rate_details.applicable_inflation_rates.in_range(start, end_d)
  end

  #private

  def item_months(st, ed)
    dates = (st..ed).each_with_object([]) { |d, o|
      o << [Date.civil(d.year, d.month, 1), Date.civil(d.year, d.month, -1)] }.uniq
    months = dates.each_with_object([]) { |d, o|
      o << {start_date: d[0], end_date: d[1], full: true }
    }
    unless months.first[:start_date]==st
      months.first[:start_date]=st
      months.first[:full]=false
      months.first[:days]=start_month_days(st)
    end
    unless months.last[:end_date]==ed
      months.last[:end_date]=ed
      months.last[:full]=false
      months.last[:days]=ed.day
    end
    months
  end

  def monthly_calculated_salary
    @monthly_base_salary*perc_chrgd
  end

  def monthly_calc_cost_share
    @monthly_base_salary*cost_sharing_percentage
  end

  def daily_salary(date)
    @monthly_base_salary/days_in_month(date.year, date.month)
  end

  def end_mnth_calc_cost_sharing
    end_month_daily_salary*end_d.day*cost_sharing_percentage
  end

  def start
    datify @start_date
  end

  def end_d
    datify @end_date
  end

  def perc_chrgd
    @percent_charged.to_f/100
  end

  def cost_sharing_percentage
    (@percent_effort.to_f-@percent_charged.to_f)/100
  end

  def update_from_parent(period_number)
    @period_number=period_number
  end

end

class AssignedPersonnelCollection < CollectionFactory

  include Foundry

  attr_reader :rates

  contains AssignedPerson
  undef_method :add

  def add(personnel_rates, opts={})
    @rates ||= []
    person = AssignedPerson.new @browser, opts
    person.create
    if @rates.empty?
      funkify(person, personnel_rates)
    else
      r = @rates.find { |r| r.object_code==person.object_code }
      if r.nil?
        funkify(person, personnel_rates)
      else
        person.rate_details = r
      end
    end
    self << person
  end

  def person(name)
    self.find { |p| p.person==name }
  end

  def details_and_rates(object_code)
    @rates.find { |rate| rate.object_code==object_code }
  end

  private

  def funkify(person, personnel_rates)
    rates = create PersonnelRatesObject, object_code: person.object_code, prs: personnel_rates
    @rates << rates
    person.rate_details = rates
  end

end