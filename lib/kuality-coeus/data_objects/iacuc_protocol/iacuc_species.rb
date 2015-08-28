class SpeciesGroupsObject < DataFactory

  include StringFactory

  attr_accessor :index
  attr_reader :group, :species, :pain_category, :count_type, :count,
              :strain, :usda_covered, :procedure_summary

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        group: random_alphanums_plus(10, 'Species '),
        species: '::random::',
        pain_category: '::random::',
        count_type: '::random::',
        count: rand(1..21),
        press: 'save'
    }
    set_options(defaults.merge(opts))
    requires :index, :navigate
  end

  def create
    view 'Species Groups'
    on SpeciesGroups do |page|
      page.expand_all
      if @species=='::random::'
        @species = page.species_list.sample
      end
      fill_out page, :group, :count, :species, :pain_category, :count_type

      #non-required, non-defaults
      fill_out page, :strain, :usda_covered, :procedure_summary

      page.add_species
      page.send(@press) unless @press.nil?
    end
  end

  def edit opts={}
    view 'Species Groups'
    on SpeciesGroups do |edit|
      edit.expand_all

      if opts[:species] == '::random::'
        opts[:species] = (edit.species_list - [@species]).sample
      end

      #need to set options here to capture the changes to these new fields.
      # TODO: This breaks with TestFactory convention. See if it is ACTUALLY
      # necessary to set options first, rather than using the opts Hash contents,
      # like is done in other #edit methods in other data objects.
      set_options(opts)

      edit.group_added(@index).fit @group
      edit.count_added(@index).fit @count
      edit.strain_added(@index).fit @strain
      edit.usda_covered_added(@index).fit @usda_covered
      edit.procedure_summary_added(@index).fit @procedure_summary
      edit.species_added(@index).pick! @species
      edit.pain_category_added(@index).pick! @pain_category
      edit.count_type_added(@index).pick! @count_type
      edit.send(@press) unless @press.nil?
    end
  end

  def view(tab)
    @navigate.call
    on(IACUCProtocolOverview).send(damballa(tab))
  end

  def delete
    on SpeciesGroups do |page|
      page.delete(@index)
    end
    on(Confirmation).yes
  end

  def update_from_parent(navigation_lambda)
    @navigate=navigation_lambda
  end

end #SpeciesGroupsObject

class SpeciesGroupsCollection < CollectionsFactory

  contains SpeciesGroupsObject

  def delete(index)
    self[index].delete
    self.delete_at(index)
    # need to reindex collection now...
  end

end