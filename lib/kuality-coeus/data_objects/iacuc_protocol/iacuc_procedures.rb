class IACUCProceduresObject < DataFactory


  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required, :location

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        procedure_index: rand(0..18) ,
        #Procedures html on checkboxes do not have unique tags, had to use index number.

        species_name_type: '::random::',
    }
    set_options(defaults.merge(opts))
  end

  def create
    view('Procedures')
    on IACUCProcedures do |page|
      page.expand_all
      #gather the included categories
      # included_categories_array = []
      # page.procedures_table.checkboxes.each {|cb| included_categories_array << cb.name }
      # DEBUG.message "The array is: #{included_categories_array}"

      # page.procedures_table.checkbox(name: included_categories_array.sample).set

      page.category(@procedure_index).set
      page.select_species(@procedure_index).pick! @species_name_type
      page.add_species(@procedure_index)
    end
  end

  def view(tab)
    on(IACUCProcedures).procedure_tab(tab.downcase)
  end

  def assign_procedure
    view_procedure('Personnel')
    on IACUCProcedures do |page|
      page.edit_procedures
      #set to all
      page.all_procedures
      page.save_procedure
    end
  end

  def set_location opts={}
    @location = {
        type: 'Performance Site',
        name: '::random::',
        room: rand(100..999),
        description: random_alphanums_plus
    }

    @location.merge!(opts)

    view_procedure('Location')
    on IACUCProcedures do |page|
      page.location_type.pick! @location[:type]
      page.location_name.pick! @location[:name]
      page.location_room.fit @location[:room]
      page.location_description.fit @location[:description]
      page.add_location
      # Afer adding the location, need to select the procedures for this location
      page.location_edit_procedures
      page.all_procedures.set
      page.save_procedure
      DEBUG.message "puts location hash: on data object is #{@location}"
    end
  end

end