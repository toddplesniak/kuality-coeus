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
    requires :person, :monthly_base_salary
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
    ((middle_months_count*monthly_calculated_salary) +
        start_month_calculated_salary +
        end_month_calculated_salary +
        salary_inflation
    ).round(2)
  end

  def cost_sharing
    ((middle_months_count*monthly_calc_cost_share) +
        start_month_calc_cost_share +
        end_mnth_calc_cost_sharing
    ).round(2)
  end

  def rate_cost(rate)
    #(requested_salary*(rate.to_f/100)).round(2)
  end

  def rate_cost_sharing(rate)
    #(cost_sharing*(rate.to_f/100)).round(2)
  end

  def salary_inflation
    if inflation_rates.empty?
      0.0
    else
      amounts = []
      inflation_rates.each { |rate|
        if rate.start_date < start
          amounts << 0
        else


          #DEBUG.message 'Rate range start date:'
          #DEBUG.inspect rrsd(rate)
          #DEBUG.message 'Rate range end date:'
          #DEBUG.inspect rred(rate)
          DEBUG.inspect start_month_inflation(rate)
          DEBUG.inspect inflated_months_count(rate)
          DEBUG.inspect monthly_calculated_salary
          DEBUG.inspect remci(rate)
          DEBUG.inspect end_month_calculated_salary
          DEBUG.inspect start_month_calculated_salary


          amounts << start_month_inflation(rate) +
              (monthly_calculated_salary*inflated_months_count(rate)*rate.applicable_rate.to_f/100) +
              remci(rate)
        end
      }
      amounts.inject(0, :+)
    end
  end

  def inflation_rates
    @rate_details.applicable_inflation_rates.in_range(start, end_d)
  end

  private

  # Rate range start date...
  def rrsd(rate)
    rate.start_date > start ? rate.start_date : start
  end
  # Rate range end date...
  def rred(rate)
    rate.end_date > end_d ? end_d : rate.end_date
  end

  def start_month_days
    days_prior = start.day-1
    days_in_start_month - days_prior
  end

  # range start month days
  def rsmd(rate)
    days_prior = rrsd(rate).day-1
    rdism(rate) - days_prior
  end

  def days_in_start_month
    days_in_month(start.year, start.month)
  end

  def rdism(rate)
    days_in_month(rrsd(rate).year, rrsd(rate).month)
  end

  def start_month_full?
    start.day == 1
  end

  def days_in_end_month
    days_in_month(end_d.year, end_d.month)
  end

  def rdiem(rate)
    days_in_month(rred(rate).year, rred(rate).month)
  end

  def start_and_end_month_same?
    end_d.year == start.year && end_d.month == start.month
  end

  def rate_sems?(rate)
    rred(rate).year == rrsd(rate).year && rred(rate).month == rrsd(rate).month
  end

  def monthly_calculated_salary
    @monthly_base_salary*perc_chrgd
  end

  def monthly_calc_cost_share
    @monthly_base_salary*cost_sharing_percentage
  end

  def start_month_daily_salary
    @monthly_base_salary/days_in_start_month
  end

  # Rate start month inflation...
  def start_month_inflation(rate)
    if rdism(rate)==rsmd(rate)
      0.0
    else
      (@monthly_base_salary/rdism(rate))*(rate.applicable_rate.to_f/100)*rsmd(rate)
    end
  end

  def end_month_daily_salary
    start_and_end_month_same? ? 0 : @monthly_base_salary/days_in_end_month
  end

  def rate_end_month_calc_salary(rate)
    rate_sems?(rate) ? 0 : monthly_calculated_salary/rdiem(rate)
  end

  def start_month_calculated_salary
    start_month_daily_salary*start_month_days*perc_chrgd
  end

  def start_month_calc_cost_share
    start_month_daily_salary*start_month_days*cost_sharing_percentage
  end

  def end_month_calculated_salary
    end_month_daily_salary*end_d.day*perc_chrgd
  end

  def remci(rate)
    rate_end_month_calc_salary(rate)*rred(rate).day*(rate.applicable_rate.to_f/100)
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

  def middle_months_count
    x = (end_d.year - start.year)*12 + end_d.month - start.month - 1
    x < 0 ? 0 : x
  end

  def inflated_months_count(rate)
    x = (rred(rate).year - rrsd(rate).year)*12 + rred(rate).month - rrsd(rate).month
    x < 0 ? 0 : x
  end

  def perc_chrgd
    @percent_charged.to_f/100
  end

  def cost_sharing_percentage
    (@percent_effort.to_f-@percent_charged.to_f)/100
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