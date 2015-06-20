class IACUCProceduresObject < DataFactory

  include StringFactory, DateFactory, Protocol

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :protocol_project_type, :lay_statement_1, :alternate_search_required, :location,
               :set_location,
               :procedure_list, :procedure_name, :qualifications

  def initialize(browser, opts={})
    @browser = browser
    # the order of objects in this array correspond to the line index on the page
    #if there are fails try checking the order of the list
    @procedure_list = ['Analgesics', 'Anesthesia', 'Paralytics',
      'Survival', 'Multiple Major Survival',
      'Non-survival', 'Medical Device Testing',
      'Food/water restriction (not prior to surgery)',
      'Chemical Method', 'Physical Method',
      'Radioactive isotopes', 'Irradiation', 'Aversive Stimuli',
      'Antibody Production', 'Immunization',
      'Blood sampling', 'Nutritional studies',
      'Physical restraint', 'Chemical restraint']

    defaults = {
        procedure_name: @procedure_list.sample,
        species_name_type: '::random::',
        qualifications: random_alphanums,
        locations:      collection('ProcedureLocations')
    }
    set_options(defaults.merge(opts))
    requires :navigate
  end

  def create
    @procedure_index = @procedure_list.index(@procedure_name)
    view
    on IACUCProcedures do |page|
      page.category(@procedure_index).set
      page.select_species(@procedure_index).pick! @species_name_type
      page.add_species(@procedure_index)
    end
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
    on(IACUCProcedures).select_procedure_tab 'Personnel'
    on(IACUCProceduresPersonnel).edit_procedures(person_name)

    on IACUCProceduresPersonnelDialogue do |page|
      page.procedure(procedure_name)
      page.qualifications.fit @qualifications
      page.save
    end
  end

  def add_location opts={}
    defaults = {
      navigate: @navigate
    }
    view
    on(IACUCProcedures).select_procedure_tab 'Location'
    @locations.add defaults.merge(opts)
  end


end   # IACUCProceduresObject

class ProceduresCollection < CollectionsFactory

  contains IACUCProceduresObject

end