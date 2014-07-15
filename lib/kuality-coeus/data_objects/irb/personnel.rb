class ProtocolPersonnelObject < DataFactory

  include StringFactory, Personnel

  attr_reader :first_name, :last_name, :full_name, :user_name,
              :role

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        type: 'employee'
    }

    set_options(defaults.merge(opts))
    requires :role
  end

  def create
    get_person
    on page_class do |page|
      page.protocol_role.fit @role
      page.add_person
      page.save
    end
  end

  private

  def page_class
    ProtocolPersonnel
  end

end

class ProtocolPersonnelCollection < CollectionsFactory

  contains ProtocolPersonnelObject

  include People

end