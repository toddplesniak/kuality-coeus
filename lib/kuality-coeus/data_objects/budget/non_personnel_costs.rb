class NonPersonnelCost < DataFactory

  include StringFactory

  attr_reader :category_type, :category_code, :object_code_name, :total_base_cost,
              :quantity, :description

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      category_type:    '::random::',
      object_code_name: '::random::',
      total_base_cost:  random_dollar_value(1000000),
      quantity:         rand(5),
      description:      random_alphanums
    }

    set_options(defaults.merge(opts))
  end

  def create
    # Navigation is handled by the Budget Period object
    on(NonPersonnelCosts).assign_non_personnel
    on AddAssignedNonPersonnel do |page|
      page.category.pick! @category_type
      page.loading
      fill_out page, :object_code_name, :total_base_cost,
               :quantity, :description
      page.add_non_personnel_item
    end
  end
end

class NonPersonnelCostsCollection < CollectionFactory

  contains NonPersonnelCost

end