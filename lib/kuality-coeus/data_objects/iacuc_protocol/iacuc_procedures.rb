class IACUCProceduresObject < DataFactory

  include StringFactory, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required, :locations, :categories,
               :qualifications

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        categories: collection('ProcedureCategories'),
        species_name_type: '::random::',
        qualifications: random_alphanums,
        locations:      collection('ProcedureLocations')
    }
    set_options(defaults.merge(opts))
    requires :navigate
  end

  def create
    view
    add_category
  end

  def add_category opts={}
    @categories.add opts
  end

  def view
    @navigate.call
    on(IACUCProtocolOverview) do |page|
      page.procedures
      page.expand_all
    end
  end

  def assign_personnel(person_name, procedure_name)
    view
    on(IACUCProcedures).select_procedure_tab 'personnel'
    on(IACUCProceduresPersonnel).edit_procedures(person_name)

    on IACUCProceduresPersonnelDialogue do |page|
      page.procedure(procedure_name)
      page.qualifications.fit @qualifications
      page.save
    end
  end

  def add_location opts={}
    defaults = {
      navigate: @navigate,
      index: @locations.size
    }
    view
    on(IACUCProcedures).select_procedure_tab 'location'
    @locations.add defaults.merge(opts)
  end

end   # IACUCProceduresObject