class IACUCLocationNameMaintenanceObject < DataFactory

  include StringFactory

  attr_reader :location_name_code, :location_name, :location_type_code

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:        random_alphanums,
        location_name_code: rand(900...999),
        location_type_code:      '::random::',
        location_name: random_alphanums,
        press: 'blanket_approve'
    }
    set_options(defaults.merge(opts))
  end

  def create
    visit(Maintenance).iacuc_location_name
    on(LocationNameLookup).create
    on LocationNameMaintenance do |page|
      fill_out page, :description, :location_name_code, :location_name, :location_type_code
      page.send(@press) unless @press.nil?
    end
  end
end