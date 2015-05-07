# This class is specifically for personnel assigned to a period. Not for persons
# who have been added to the Budget ("Project Personnel"). That is the BudgetPersonnelObject class.
class AssignedPerson < DataFactory

  include Utilities, DateFactory

  attr_reader :person, :object_code, :group, :start_date,
              :end_date, :percent_effort, :percent_charged,
              :period_type, :requested_salary

  def initialize(browser, opts={})
    @browser = browser
    percent = rand(99)+1
    defaults = {
      object_code:         '::random::',
      group:               'Default',
      percent_effort:      percent.to_s,
      percent_charged:     (percent*0.8).round(2).to_s,
      period_type:         '::random::',
      monthly_base_salary: 0.0,
    }
    set_options(defaults.merge(opts))
    requires :person, :period_rates
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
    get_rates
    on DetailsAndRates do |page|
      fill_out page, :apply_inflation
      page.save_changes
    end
    on(AssignPersonnelToPeriods).save


    DEBUG.inspect @rates

    DEBUG.pause 2312



  end

  def requested_salary
    ((middle_months_count*monthly_calculated_salary) + (monthly_inflation_cost*inflated_months_count) + start_month_calculated_salary + end_month_calculated_salary + end_month_inflation_cost).round(2)
  end

  def cost_sharing
    ((middle_months_count*monthly_calc_cost_share) + start_month_calc_cost_share + end_mnth_calc_cost_sharing ).round(2)
  end

  def rate_cost(rate)
    (requested_salary*(rate.to_f/100)).round(2)
  end

  def rate_cost_sharing(rate)
    (cost_sharing*(rate.to_f/100)).round(2)
  end

  private

  def start_month_days
    days_prior = start.day-1
    days_in_start_month - days_prior
  end

  def days_in_start_month
    days_in_month(start.year, start.month)
  end

  def start_month_full?
    start.day == 1
  end

  def days_in_end_month
    days_in_month(end_d.year, end_d.month)
  end

  def end_month_full?
    end_d.day == days_in_end_month
  end

  def start_and_end_month_same?
    end_d.year == start.year && end_d.month == start.month
  end

  def monthly_calculated_salary
    monthly_base_salary*perc_chrgd
  end

  def monthly_calc_cost_share
    monthly_base_salary*cost_sharing_percentage
  end

  def monthly_inflation_cost
    monthly_calculated_salary*(@inflation_rate.to_f/100)
  end

  def start_month_daily_salary
    monthly_base_salary/days_in_start_month
  end

  def end_month_daily_salary
    start_and_end_month_same? ? 0 : monthly_base_salary/days_in_end_month
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

  def end_mnth_calc_cost_sharing
    end_month_daily_salary*end_d.day*cost_sharing_percentage
  end

  def end_month_inflation_cost
    end_month_calculated_salary*(@inflation_rate.to_f/100)
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

  def inflated_months_count
    x = (end_d.year - rate_start.year)*12 + end_d.month - rate_start.month
    x < 0 ? 0 : x
  end

  def perc_chrgd
    @percent_charged.to_f/100
  end

  def cost_sharing_percentage
    (@percent_effort.to_f-@percent_charged.to_f)/100
  end

  def get_rates
    @rates = @period_rates.personnel.in_range(start, end_d)
    @rates << @period_rates.inflation.in_range(start, end_d)
    @rates.flatten!
    @rates.delete_if { |r| r.on_campus != Transforms::YES_NO[@on_campus] }
    @rates.delete_if { |r| r.rate_class_type=='Inflation' && !@ird.include?(r.description) }
    @rates.delete_if { |r| r.rate_class_type=='Inflation' && start_date_datified < r.start_date }
    @rates.delete_if { |r| r.rate_class_type == 'F & A' && @overhead==false }
  end

end

class AssignedPersonnelCollection < CollectionFactory

  contains AssignedPerson

  def person(name)
    self.find { |p| p.person==name }
  end

end