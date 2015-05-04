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
      if page.inflation_rates_table.present?

        DEBUG.inspect page.inflation_rates_table[0][:description]

        inflation = @rates.inflation.keep_if { |r| r.description == page.inflation_rates_table[0][:description] }

        DEBUG.inspect inflation

        #DEBUG
        #@rates.each { |rate| puts rate.rate_class_code }

      else

        DEBUG.message 'WTF???'

        @rates = @rates - @rates.inflation
      end

      #DEBUG.inspect @rates
      DEBUG.pause 3333

      fill_out page, :apply_inflation, :submit_cost_sharing, :on_campus
      page.save_changes
    end
  end

end