class ProtocolPersonnelObject < DataFactory

  include StringFactory, Personnel

  attr_reader :first_name, :last_name, :full_name, :user_name,
              :role

  def initialize(browser, opts={})
    @browser = browser

    defaults = {

    }

    set_options(defaults.merge(opts))
    requires :role
  end

  def create

  end

end

class ProtocolPersonnelCollection < CollectionsFactory

  contains ProtocolPersonnelObject

  include People

end