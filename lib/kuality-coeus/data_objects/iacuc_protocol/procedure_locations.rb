class ProcedureLocationObject < DataFactory

  attr_reader :description, :type, :index, :name, :room

  def initialize(browser, opts={})
    @browser = browser
    defaults ={
        description: random_alphanums,
        type: 'Performance Site',
        name: '::random::',
        #Room Number required for setting the procedure to location
        room: rand(101..999)
    }
    set_options(defaults.merge(opts))
    requires :navigate
  end

  def create
    # Navigation performed by parent Procedures object
    on IACUCProceduresLocation do |page|
      #noko to speed up select list
      @type = page.location_type_list.sample if @type=='::random::'
      page.location_type.pick! @type
      page.location_room.fit @room
      page.location_description.fit @description

      # Cannot have location with same type and name so we need to handle
      # this case when location name is ::random:: for the additional name(s)
      if page.info_line('1').present? && @name == '::random::'
        loc_names = []
        # Creating an array of location names from the select list
        page.location_name_array(loc_names)
        # Deleting the existing location name at index zero
        loc_names.delete(page.location_name_added(0).selected_options.first.text)
        page.location_name.pick! loc_names.sample
        @name = page.location_name.selected_options.first.text
      else
        # No previous locations, so we add the first one
        page.location_name.pick! @name
      end

      page.add_location
      # After adding the location, need to select the procedures for this location
      # otherwise this location will not be saved
      # Need to use the info line number with room value to find the correct edit procedures button
      @info_line_number = page.info_line_number(@room)
      page.location_edit_procedures(@info_line_number)
    end
    # Select the specific species checkbox if provided otherwise select the ALL option.
    on IACUCProceduresPersonnelDialogue do |page|
      if page.all_group.parent.text.strip == @location[:species]
        page.all_group.set
      else
        page.all_procedures
      end
      page.save
    end

    on(IACUCProceduresLocation).save
  end

  def view
    @navigate.call
    on(IACUCProcedures) do |page|
      page.procedures
      page.expand_all
      page.select_procedure_tab 'Location'
    end
  end

  def edit opts={}
    # TODO: Navigation stuff
    view
    on IACUCProceduresLocation do |page|
      page.type_added(@index).fit opts[:type]
      page.name_added(@index).fit opts[:name]
      page.room_added(@index).fit opts[:room]
      page.description_added(@index).fit opts[:description]
      page.edit_procedures(@index)
      page.save
      update_options(opts)
    end
  end

  def delete
    view
    on IACUCProcedures do |page|
      page.expand_all
    end
    view_procedure_details 'Location'
    on IACUCProceduresLocation do |page|
      page.location_delete(@index)
      confirmation
      page.save
    end
  end

end  # ProcedureLocationObject

class ProcedureLocationsCollection < CollectionsFactory

  contains ProcedureLocationObject

end