class PersonnelRatesObject < DataFactory

  attr_reader :apply_inflation, :submit_cost_sharing, :on_campus,
              :object_code, :inflation_rates

  def initialize(browser, opts={})
    @browser = browser
    defaults ={
      apply_inflation: 'Yes',
      submit_cost_sharing: 'Yes',
      on_campus: 'Yes',
      rates: collection('BudgetRates')
    }
    set_options defaults.merge(opts)
    requires :object_code, :prs
  end

  def create
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
  end

end