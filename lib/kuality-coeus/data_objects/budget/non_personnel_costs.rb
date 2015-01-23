class NonPersonnelCost < DataFactory

  include StringFactory

  attr_reader :category_type, :category_code, :object_code_name, :total_base_cost

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      category_type:    '::random::',
      object_code_name: '::random::',
      total_base_cost:  random_dollar_value(1000000)
    }

    set_options(defaults.merge(opts))
  end

  def create
    # Navigation is handled by the Budget Period object
    on(NonPersonnelCosts).assign_non_personnel
    on AddAssignedNonPersonnel do |page|
      page.category.pick! @category_type
      page.loading
      page.object_code_name.pick! @object_code_name
      page.total_base_cost.fit @total_base_cost
      page.add_non_personnel_item
    end
  end
end

class NonPersonnelCostsCollection < CollectionFactory

  contains NonPersonnelCost

end