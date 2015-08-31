class AwardKeyPersonObject < DataFactory

  include Personnel

  attr_reader :employee_user_name, :non_employee_id, :project_role,
              :key_person_role, :first_name, :last_name, :full_name,
              :lead_unit, :type, :responsibility, :financial, :recognition,
              :space, :key_person_role, :get_units

  attr_accessor :units

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        type:            'employee',
        project_role:    'Principal Investigator',
        units:           [], # Contains Hashes with Keys... :number, :name, :recognition, :responsibility, :space, :financial
        key_person_role: random_alphanums,
        get_units: 'yes'
    }

    set_options(defaults.merge(opts))
    @full_name = @type=='employee' ? "#{@first_name} #{@last_name}" : "#{@last_name}, #{@first_name}"
    requires :navigate
  end

  # Navigation done by parent object...
  def create
    on(AwardContacts).expand_all
    added_persons = []

    if @type == 'employee'
      on AwardContacts do |page|
        begin
          added_persons = page.people_present
        rescue
          added_persons = []
        end
        page.employee_search
      end

      on KcPersonLookup do |lookup|
        lookup.last_name.fit @last_name
        lookup.first_name.fit @first_name
        lookup.search
        #return random person if that person is not already on award
        people_array = lookup.returned_full_names - $users.full_names - added_persons

        @full_name = people_array.sample
        # lookup.select_person(select_person[1])
        lookup.return_value(@full_name)
      end

    else #Non-employee
      on AwardContacts do |page|
        page.non_employee_search
        #Non-Organizational Address Book Lookup
      end
      on NonOrgAddressBookLookup do |lookup|
        lookup.search
        #TODO:: need to return random of a person that is not already added to award
        lookup.return_random
      end
      #set up name
      on AwardContacts do |page|
        page.kp_non_employee_id.wait_until_present
        @full_name = page.kp_non_employee_id.value.strip
        @first_name = @full_name.partition(',').first.strip
        @last_name =  @full_name.partition(',').last.strip
      end

    end #to employee or non-employee

    on AwardContacts do |page|
      page.kp_project_role.wait_until_present
      case @project_role
        when 'Principal Investigator' || 'PI/Contact'
          page.kp_project_role.select_value 'PI'
        when 'Key Person'
          page.key_person_role.fit @key_person_role
        else
          page.kp_project_role.select @project_role
      end

      page.add_key_person
      page.expand_all
      #need to remove spaces and commas because of the way the div is constructed
      @full_name_no_spaces = @full_name.gsub(' ', '').gsub(',', '')
      if @get_units == 'yes' && @role != 'Key Person'
        @units = page.units(@full_name_no_spaces)
        @units.uniq!
      end
    end
  end  #create

  def edit opts={}
    # TODO: Add navigation
    on AwardContacts do |update|
      update.expand_all
      # TODO: This will eventually need to be fixed...
      # Note: This is a dangerous short cut, as it may not
      # apply to every field that could be edited with this
      # method...
      opts.each do |field, value|
        update.send(field, @full_name).fit value
      end
      #need to handle edit of project role need to use ()value: 'PI'), for cases 'Principal Investigator' and 'PI/Contact'
      update.save
    end
    update_options(opts)
  end #edit

  #deletes a key person
  def delete
    on AwardContacts do |delete|
       DEBUG.message "is this delete on KP being called? #{@full_name}"
       delete.expand_all
       delete.delete_person(@full_name)
       delete.save
    end
    #TODO:: Remove from data object
  end

  # TODO: Some of this method should be moved to the Personnel
  # module at some point, so it can be used by the KeyPersonObject.
  def add_unit(unit_number, lead=false)
    # TODO: Add conditional navigation
    on AwardContacts do |add_unit|
      add_unit.expand_all
    end

    if unit_number == '::random::'
      on AwardContacts do |add_unit|
        add_unit.unit_lookup_for_person(@full_name)
      end
      on UnitLookup do |lookup|
        lookup.search
        lookup.return_random
      end
      on AwardContacts do |add_unit|
        add_unit.add_lead_unit(@full_name) if lead
        add_unit.add_unit(@full_name)
        @units << add_unit.units(@full_name)
        @units.flatten!
      end
    else
      on AwardContacts do |add_unit|
        add_unit.add_lead_unit(@full_name) if lead
        add_unit.add_unit_number(@full_name).set unit_number
        add_unit.add_unit(@full_name)
        @units << {number: unit_number, name: add_unit.unit_name(@full_name, unit_number) }
        confirmation 'no'
      end
    end

    on AwardContacts do |add_unit|
      add_unit.save
    end
    @lead_unit=unit_number if lead
  end

  def add_random_unit(lead=false)
    add_unit('::random::', lead)
  end

  def add_lead_unit(unit_number)
    add_unit(unit_number, true)
  end

  def set_lead_unit(unit_number)
    # TODO: Add conditional navigation
    #Note: Editing a project_role to be the PI will require the page to be saved
    # before radio buttons appear for the new PI
    on AwardContacts do |page|
      page.expand_all
      page.lead_unit_radio(@full_name, unit_number).set
      page.save
    end
  end

  def delete_unit(unit_number)
    # TODO: Add conditional navigation
    on AwardContacts do |delete_unit|
      delete_unit.delete_unit(@full_name, unit_number)   if delete_unit.delete_unit_element(@full_name, unit_number).present?
      delete_unit.save
    end
    @units.delete(unit_number)
  end

  def update_from_parent(id, navigation_lambda)
    @document_id=id
    @navigate=navigation_lambda
  end

  def update_splits opts={}
    view 'Contacts'
    on AwardContacts do |page|
      page.expand_all
      edit_item_fields opts, @full_name, page, :financial, :responsibility
      page.save
    end
    update_options(opts)
  end

  def view(tab)
    @navigate.call
    unless on(Award).send(StringFactory.damballa("#{tab}_element")).parent.class_name=~/tabcurrent$/
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end


  def update_unit_splits(unit_number, opts)
    on CombinedCreditSplit do |page|
      opts.each do |type, value|
        page.send("unit_#{type}", @full_name, unit_number).fit value
      end
      page.save
    end
    # @units.find{ |u| u[:number]==unit_number}.merge!(opts)
  end

  #Units is an array from key personnel object
  def update_unit_splits_to_valid(units=@units)
    on AwardContacts do |page|
      page.expand_all
      #for each unit set value of responsibility and financial
      if units.count == 1
        #person has only one unit
        units.flatten!
        page.unit_responsibility(@full_name, units[0][:name]).fit '100.00'
        page.unit_financial(@full_name, units[0][:name]).fit '100.00'
      else
        #User has multiple units need to set values for each one.
        split = (100.0/units.count).round(2)

        units.each do |unit|
          #person has multiple units that need to equal 100
          page.unit_responsibility(@full_name, unit[:name]).set split
          page.unit_financial(@full_name, unit[:name]).set split
        end
      end
      page.recalculate
      page.save
    end
  end



end  #AwardKeyPersonObject

class AwardKeyPersonnelCollection < CollectionsFactory

  contains AwardKeyPersonObject
  include People

  def principal_investigator
    self.find{ |person| person.project_role=='Principal Investigator' || person.project_role=='PI/Contact' }
  end

  def co_investigator
    self.find{ |person| person.project_role=='Co-Investigator' }
  end

  def co_investigators
    self.find_all { |person| person.project_role=='Co-Investigator' }
  end

  def with_units
    self.find_all { |person| person.units.size > 0 }
  end

  def validate_units
    self.each {|person| person.add_random_unit unless person.units.size > 0 }
  end

  def delete(person)
    p = self.find { |p| p.full_name==person }
    DEBUG.message "person to delete is"
    DEBUG.inspect p
    p.delete
    self.delete_if { |p| p.full_name==person }

    # DEBUG.inspect self

  end

end