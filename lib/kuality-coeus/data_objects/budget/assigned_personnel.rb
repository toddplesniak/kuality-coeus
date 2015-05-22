# This class is specifically for personnel assigned to a period. Not for persons
# who have been added to the Budget ("Project Personnel"). That is the BudgetPersonnelObject class.
class AssignedPerson < DataFactory

  include Utilities, DateFactory

  attr_reader :person, :object_code, :group, :start_date,
              :end_date, :percent_effort, :percent_charged,
              :period_type, :requested_salary
  attr_accessor :rate_details, :monthly_base_salary
  def_delegators :@rate_details, :rates

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
    summary_calc(:salary)
  end

  def cost_sharing
    summary_calc(:cost_sharing)
  end

  def indirect_costs
    costs = { cost: 0, cost_sharing: 0 }
    item_months.each { |m|
      cur = current_indirect_rate(m)
      if cur.nil?
        costs[:cost] += 0
        costs[:cost_sharing] += 0
      end
      direct = [0]
      cost_share = [0]
      direct_costs.each { |dc|
        rates = @rate_details.applicable_direct_rates.description(dc[:description])
        rate = current_rate(rates, m)
        if rate.nil?
          # skip
        else
          direct << rate_cost(m, rate)
          cost_share << rate_cost_sharing(m, rate)
        end
      }
      costs[:cost] += direct.inject(:+)*cur.applicable_rate.to_f/100
      costs[:cost_sharing] += cost_share.inject(:+)*cur.applicable_rate.to_f/100
      if m[:full]
        costs[:cost] += (monthly_calculated_salary+salary_inflation(m))*cur.applicable_rate.to_f/100
        costs[:cost_sharing] += (monthly_calc_cost_share+cost_sharing_inflation(m))*cur.applicable_rate.to_f/100
      else
        costs[:cost] += (daily_salary(m[:start_date])*m[:days]*perc_chrgd+salary_inflation(m))*cur.applicable_rate.to_f/100
        costs[:cost_sharing] += (daily_salary(m[:start_date])*m[:days]*cost_sharing_percentage+cost_sharing_inflation(m))*cur.applicable_rate.to_f/100
      end
    }
    costs
  end

  def direct_costs
    items = @rate_details.applicable_direct_rates.map { |rate| {description: rate.description} }.uniq
    items.each do |item|
      item[:cost] = rate_calc(:rate_cost, item[:description])
      item[:cost_share] = rate_calc(:rate_cost_sharing, item[:description])
    end
    items
  end

  def update_from_parent(period_number)
    @period_number=period_number
  end

  # =======
  private
  # =======

  def summary_calc(type)
    types = {
        salary: [monthly_calculated_salary, perc_chrgd, :salary_inflation],
        cost_sharing: [monthly_calc_cost_share, cost_sharing_percentage, :cost_sharing_inflation]
    }
    amounts = []
    item_months.each { |m|
      if m[:full]
        x = types[type][0]
      else
        x = daily_salary(m[:start_date])*types[type][1]*m[:days]
      end
      amounts << x + send(types[type][2], m)
    }
    amounts.inject(0, :+)
  end

  def rate_calc(type, description)
    amounts = []
    rates = @rate_details.applicable_direct_rates.description(description)
    item_months.each { |m|
      if current_rate(rates, m).nil?
        amounts << 0
        next
      end
      amounts << send(type, m, current_rate(rates, m))
    }
    amounts.inject(0, :+)
  end

  def rate_cost_sharing(range, rate)
    if range[:full]
      x = monthly_calc_cost_share*rate.applicable_rate.to_f/100
    else
      x = daily_salary(range[:start_date])*cost_sharing_percentage*range[:days]*rate.applicable_rate.to_f/100
    end
    x + cost_sharing_inflation(range)*rate.applicable_rate.to_f/100
  end

  def rate_cost(range, rate)
    ((daily_salary(range[:start_date])*range[:days]*perc_chrgd)+salary_inflation(range))*(rate.applicable_rate.to_f/100)
  end

  def salary_inflation(range)
    calculate_inflation(:salary, range)
  end

  def cost_sharing_inflation(range)
    calculate_inflation(:cost_share, range)
  end

  def calculate_inflation(type, range)
    types = {
        salary: [monthly_calculated_salary, perc_chrgd],
        cost_share: [monthly_calc_cost_share, cost_sharing_percentage]
    }
    rate_to_apply = current_inflation_rate(range[:start_date], range[:end_date])
    return 0 if rate_to_apply.nil?
    #TODO: Calculate value if the rate ends earlier than month end...
    if range[:full]
      types[type][0]*rate_to_apply.applicable_rate.to_f/100
    else
      daily_salary(range[:start_date])*range[:days]*types[type][1]*rate_to_apply.applicable_rate.to_f/100
    end
  end

  def current_inflation_rate(date_start, date_end)
    r = @rate_details.applicable_inflation_rates.in_range(start, end_d).find { |rate|
      rate.start_date <= date_start && rate.end_date >= date_end
    }
    unless r.nil?
      r = nil if r.start_date < start && @period_number==1
    end
    r
  end

  def current_indirect_rate(range)
    rate = @rate_details.applicable_f_and_a_rates.find { |r| r.start_date <= range[:start_date] && r.end_date >= range[:end_date] }
    rate = @rate_details.applicable_f_and_a_rates.find_all { |r| r.start_date <= m[:start_date] }.sort { |r| r.start_date }[-1] if rate.nil?
    rate
  end

  def current_rate(rates, range)
    current_rate = rates.find { |r| r.start_date <= range[:start_date] && r.end_date >= range[:end_date] }
    current_rate = rates.find_all { |r| r.start_date <= range[:start_date] }.sort { |r| r.start_date }[-1] if current_rate.nil?
    current_rate
  end

  def item_months
    dates = (start..end_d).each_with_object([]) { |d, o|
      o << [Date.civil(d.year, d.month, 1), Date.civil(d.year, d.month, -1)] }.uniq
    months = dates.each_with_object([]) { |d, o|
      o << {start_date: d[0], end_date: d[1], full: true, days: d[1].day }
    }
    unless months.first[:start_date]==start
      months.first[:start_date]=start
      months.first[:full]=false
      months.first[:days]=start_month_days
    end
    unless months.last[:end_date]==end_d
      months.last[:end_date]=end_d
      months.last[:full]=false
      months.last[:days]=end_d.day
    end
    months
  end

  def start_month_days
    days_prior = start.day-1
    days_in_month(start.year, start.month) - days_prior
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

  def start
    datify @start_date
  end

  def end_d
    datify @end_date
  end

  def total_days
    (end_d-start).to_i+1
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

  # Note: This currently sums up ALL direct costs. It does not keep distinctions
  # if there are multiple direct rates, like salary plus vacation, etc.
  def direct_costs
    { cost: self.map{ |p| p.direct_costs.map{ |c| c[:cost]}.inject(0, :+) + p.requested_salary }.inject(0, :+),
      cost_share: self.map { |p| p.direct_costs.map{ |c| c[:cost_share]}.inject(0, :+) }.inject(0, :+)
    }
  end

  private

  def funkify(person, personnel_rates)
    rates = create PersonnelRatesObject, object_code: person.object_code, prs: personnel_rates
    @rates << rates
    person.rate_details = rates
  end

end