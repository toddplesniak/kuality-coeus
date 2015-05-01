class PersonnelRatesObject < DataFactory

  attr_reader :rates, :apply_inflation, :submit_cost_sharing, :on_campus,
              :object_code

  def initialize(browser, opts={})
    @browser = browser
    defaults ={
      apply_inflation: 'Yes',
      submit_cost_sharing: 'Yes',
      on_campus: 'Yes'
    }
    set_options defaults.merge(opts)
    requires :object_code, :rates
  end

  def create
    on(AssignPersonnelToPeriods).details_and_rates_of @object_code
    on DetailsAndRates do |page|

      DEBUG.inspect @rates
      DEBUG.pause 3333

      fill_out page, :apply_inflation, :submit_cost_sharing, :on_campus
      page.save_changes
    end
  end

end