class IACUCProtocolObject < DataFactory

  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required, :location

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        protocol_project_type: '::random::',
        lay_statement_1:     random_alphanums_plus,
        alternate_search_required: 'No',
        personnel:           collection('ProtocolPersonnel')
    }
    @lookup_class = ProtocolLookup
    set_options(defaults.merge(opts))
  end

  def create
    visit(Researcher).create_iacuc_protocol
    on IACUCProtocolOverview do |doc|
      @document_id=doc.document_id
      @doc_header=doc.doc_title
      @status=doc.document_status
      @initiator=doc.initiator
      @submission_status=doc.submission_status
      @expiration_date=doc.expiration_date
      doc.expand_all
      fill_out doc, :description, :protocol_type, :title, :lay_statement_1
      doc.protocol_project_type.pick!(@protocol_project_type)

    end
    set_pi
    set_lead_unit
    on IACUCProtocolOverview do |doc|
      doc.save
      @protocol_number=doc.protocol_number
      @search_key = { protocol_number: @protocol_number }

    end
    #if you want to do more than just submit a protocol then this needs to be set to 'yes' or 'no'
    alternate_search_required unless @alternate_search_required.nil?

  end

  def view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    open_document
    on(IACUCProtocolOverview).send(damballa(tab)) unless @browser.frm.dt(class: 'licurrent').button.alt == tab
  end

  def view_procedure(tab)
     on(IACUCProcedures).procedure_tab(tab.downcase)
  end

  def alternate_search_required
    view("The Three R's")
    on TheThreeRs do |page|
      page.expand_all
      page.alternate_search_required.fit @alternate_search_required

      page.save
    end
  end

  def submit_for_reivew opts={}
    @review = {
        submission_type: '::random::',
        review_type: '::random::',
        type_qualifier: '::random::'
    }
    @review.merge!(opts)

    view('IACUC Protocol Actions')
    on IACUCSubmitForReview do |page|
      page.expand_all
      page.submission_type.pick! @review[:submission_type]
      page.review_type.pick! @review[:review_type]
      page.type_qualifier.pick! @review[:type_qualifier]
      page.submit
    end
  end

  def send_notification_to_employee
    on(IACUCProtocolOverview).send_notification
    on(NotificationEditor).employee_search

    on KcPersonLookup do |page|
      page.search
      page.return_random
    end

    on NotificationEditor do |page|
      page.add
      page.send_it
    end
  end

  def add_species_group opts={}
    @species = {
        name: random_alphanums_plus(10, 'Species '),
        species: '::random::',
        pain_category: '::random::',
        count_type: '::random::',
        count: rand(1..21)
    }
    @species.merge!(opts)

    view('Species Groups')
    on SpeciesGroups do |page|
      page.expand_all
      page.species_group_field.fit @species[:name]
      page.species_count.fit @species[:count]
      page.species.pick! @species[:species]
      page.pain_category.pick! @species[:pain_category]
      page.count_type.pick! @species[:count_type]
      page.add_species

      page.save
    end
  end

  def add_procedure opts={}
    @procedure = {
        procedure_index: rand(0..18),
        species_name_type: '::random::'

    }
    @procedure.merge!(opts)
    #Procedures html on checkboxes do not have unique tags, had to use index number.
    view('Procedures')
    on IACUCProcedures do |page|
      page.expand_all
      #gather the included categories
      # included_categories_array = []
      # page.procedures_table.checkboxes.each {|cb| included_categories_array << cb.name }
      # DEBUG.message "The array is: #{included_categories_array}"

      # page.procedures_table.checkbox(name: included_categories_array.sample).set

      page.category(@procedure[:procedure_index]).set
      page.select_species(@procedure[:procedure_index]).pick! @procedure[:species_name_type]
      page.add_species(@procedure[:procedure_index])
    end
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

  def add_protocol_exception opts={}
    @protocol_exception = {
        exception: '::random::',
        justification: random_alphanums_plus
    }
    @protocol_exception.merge!(opts)

    view('Protocol Exception')
    on ProtocolException do |page|
      page.expand_all
      page.exception.pick! @protocol_exception[:exception]
      page.species.pick!  @species[:species]
      page.justification.fit @protocol_exception[:justification]
      page.add_exception
    end
  end


end