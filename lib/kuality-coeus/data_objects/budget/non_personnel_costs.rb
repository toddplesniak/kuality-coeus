class NonPersonnelCost < DataFactory

  include StringFactory

  attr_reader :category_type, :category_code, :object_code_name, :total_base_cost,
              :cost_sharing, :start_date, :end_date,
              #TODO:
              :quantity, :description

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      category_type:    '::random::',
      object_code_name: '::random::',
      total_base_cost:  random_dollar_value(1000000),
    }

    set_options(defaults.merge(opts))
  end

  def create
    # Navigation is handled by the Budget Period object
    on(NonPersonnelCosts).assign_non_personnel
    on AddAssignedNonPersonnel do |page|
      page.category.pick! @category_type
      page.loading
      fill_out page, :object_code_name, :total_base_cost
      page.add_non_personnel_item
    end
  end

  def edit opts={}
    # Method assumes we're already in the right place
    on(NonPersonnelCosts).details_of @object_code_name
    on EditAssignedNonPersonnel do |page|
      @start_date ||= page.start_date.value
      @end_date ||= page.end_date.value
      edit_fields opts, page, :apply_inflation, :submit_cost_sharing,
                  :start_date, :end_date
      page.cost_sharing_tab
      edit_fields opts, page, :cost_sharing
      page.save_changes
    end
    update_options opts
  end

end

class NonPersonnelCostsCollection < CollectionFactory

  contains NonPersonnelCost

end