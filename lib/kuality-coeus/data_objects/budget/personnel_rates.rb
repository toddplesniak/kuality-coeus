class PersonnelRatesObject < DataFactory

  attr_reader :apply_inflation, :submit_cost_sharing, :on_campus,
              :object_code, :rates, :applied_rates, :unapplied_rates

  def initialize(browser, opts={})
    @browser = browser
    defaults ={
      apply_inflation: 'Yes',
      submit_cost_sharing: 'Yes',
      on_campus: 'Yes',
      rates: collection('BudgetRates'),
      unapplied_rates: []
    }
    set_options defaults.merge(opts)
    requires :object_code, :prs
  end

  def create
    # Expectation is that prior navigation is handled elsewhere
    on(AssignPersonnelToPeriods).details_and_rates_of @object_code
    on DetailsAndRates do |page|
      if page.inflation_rates_table.present?
        description = page.inflation_rates[0][:description]
        @rates << @prs.inflation.find_all { |r| r.description==description }
      end
      rate_list = page.rate_amounts
      rate_list.each { |rate|
        @rates << @prs.find_all { |r| r.description==rate[:type] }
      }
      @rates.flatten!
      fill_out page, :apply_inflation, :submit_cost_sharing, :on_campus
      page.save_changes
    end
    collect_applied_rates
  end

  def edit opts={}
    # Expectation is that prior navigation is handled elsewhere
    on(AssignPersonnelToPeriods).details_and_rates_of @object_code
    on DetailsAndRates do |page|
      edit_fields opts, page, :apply_inflation, :submit_cost_sharing, :on_campus
      page.save_changes
    end
    set_options opts
  end

  def unapply_rate(description)
    on(AssignPersonnelToPeriods).details_and_rates_of @object_code
    on DetailsAndRates do |page|
      page.rates
      page.apply(description).clear
      page.save_changes
    end
    @applied_rates.delete(description)
    @unapplied_rates << description
  end

  def applicable_inflation_rates
    if Transforms::TRUE_FALSE[@apply_inflation]
      @rates.campus(@on_campus).inflation
    else
      # Sends an empty collection...
      BudgetRatesCollection.new @browser
    end
  end

  def applicable_direct_rates
    br = BudgetRatesCollection.new @browser
    br << @rates.campus(@on_campus).direct.reject { |r| @unapplied_rates.include? r.description }
    br.flatten
  end

  def applicable_f_and_a_rates
    br = BudgetRatesCollection.new @browser
    br << @rates.campus(@on_campus).f_and_a.reject { |r| @unapplied_rates.include? r.description }
    br.flatten
  end
  alias_method :applicable_indirect_rates, :applicable_f_and_a_rates

  private

  def collect_applied_rates
    rates = []
    rates << applicable_direct_rates
    rates << applicable_f_and_a_rates
    @applied_rates = rates.flatten.map { |r| r.description }.uniq
  end

end