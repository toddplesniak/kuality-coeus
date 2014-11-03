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
    #Room Number required for setting the procedure to location
    @location ||= {
        description: random_alphanums,
        type: 'Performance Site',
        name: '::random::',
        species: 'blank',
        room: rand(101..999)
    }
    @location.merge!(opts)

    view 'Procedures'
    view_procedure_details 'Location'
    on IACUCProcedures do |page|
      page.location_type.pick! @location[:type]
      page.location_room.fit @location[:room]
      page.location_description.fit @location[:description]

      # Cannot have location with same type and name so we need to handle
      # this case when location name is ::random:: for the additional name(s)
      if page.info_line('1').present? && @location[:name] == '::random::'
       loc_names = []
       # Creating an array of location names from the select list
       on(IACUCProcedures).location_name_array(loc_names)
       # Deleting the existing location name at index zero
       loc_names.delete(page.location_name_added(0).selected_options.first.text)
       page.location_name.pick! loc_names.sample
       @location[:name] = page.location_name.selected_options.first.text
      else
        # No previous locations, so we add the first one
        page.location_name.pick! @location[:name]
      end

      page.add_location
      # After adding the location, need to select the procedures for this location
      # otherwise this location will not be saved
      # Need to use the info line number with room value to find the correct edit procedures button
      @info_line_number = page.info_line_number(@location[:room])
      page.location_edit_procedures(@info_line_number)

      # Select the specific species checkbox if provided otherwise select the ALL option.
      if page.all_group.parent.text.strip == @location[:species]
        page.all_group.set
      else
        page.all_procedures
      end
      page.save_procedure
      page.save
    end
  end

  def edit_location opts={}
    @location ||= {
        index: '0'
    }
    @location.merge!(opts)
    view 'Procedures'
    view_procedure_details 'Location'
    on IACUCProcedures do |page|
      page.expand_all
      page.location_type_added(@location[:index]).pick! @location[:type]
      page.location_name_added(@location[:index]).pick! @location[:name]
      page.location_room_added(@location[:index]).fit @location[:room]
      page.location_description_added(@location[:index]).fit @location[:description]
      page.save
    end
  end

  def delete_location(line_index)
    view 'Procedures'
    on IACUCProcedures do |page|
      page.expand_all
      view_procedure_details 'Location'
      page.location_delete(line_index.to_s)
      on(Confirmation).yes if on(Confirmation).yes_button.present?
      page.save
    end
  end

end   # IACUCProceduresObject