class IACUCProceduresObject < DataFactory

  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required, :location,
               :set_location

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        procedure_index: rand(18),
        species_name_type: '::random::'
    }
    set_options(defaults.merge(opts))
  end

  def create
    view 'Procedures'
    on IACUCProcedures do |page|
      page.expand_all

      #Procedures checkboxes do not have unique tags, have to use index number.
      page.category(@procedure_index).set
      page.select_species(@procedure_index).pick! @species_name_type
      page.add_species(@procedure_index)
    end
  end

  def view(tab)
    #navigation expects to be inside of the iacuc protocol
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    on(IACUCProtocolOverview).send(damballa(tab))
  end

  def view_procedure_details(tab)
    #for tab navigation inside the procedure details section
    on(IACUCProcedures).select_procedure_tab(tab.downcase)
  end

  def assign_procedure
    view_procedure_details 'Personnel'
    on IACUCProcedures do |page|
      page.edit_procedures
      page.all_procedures
      page.save_procedure
    end
  end

  def set_location opts={}
    @location ||= {
        description: random_alphanums,
        type: 'Performance Site',
        name: '::random::',
        species: 'blank'
    }
    @location.merge!(opts)

    view 'Procedures'
    view_procedure_details 'Location'
    on IACUCProcedures do |page|
      page.location_type.pick! @location[:type]
      page.location_name.pick! @location[:name]
      page.location_room.fit @location[:room]
      page.location_description.fit @location[:description]
      page.add_location
      # After adding the location, need to select the procedures for this location
      page.location_edit_procedures
      page.all_group.set if page.all_group.parent.text.strip == @location[:species]
      page.save_procedure
    end
  end

end   # IACUCProceduresObject