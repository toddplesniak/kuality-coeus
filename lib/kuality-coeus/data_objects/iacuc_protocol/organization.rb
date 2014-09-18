class OrganizationObject < DataFactory

  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :organization_id, :organization_type, :clear_contact, :add_contact_info,
               :old_organization_address, :organization_address

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        organization_id: '::random::',
        organization_type: '::random::',
        press: 'save'
    }
    set_options(defaults.merge(opts))
  end

  def create
    # NOTE: Navigation is accomplished in the parent Protocol object!
    on IACUCProtocolOverview do |page|
      page.expand_all

      if @organization_id == '::random::'
        page.organization_lookup
        on OrganizationLookup do |lookup|
          lookup.search
          lookup.return_random
          @organization_id = page.organization_id.value
        end
      else
        page.organization_id.fit @organization_id.value unless @organization_id.nil?
      end

      page.organization_type.pick! @organization_type unless @organization_type.nil?
      page.add_organization
      page.send(@press) unless @press.nil?
    end
  end

  def clear_contact(org_id)
    on IACUCProtocolOverview do |page|
      @old_organization_address = page.contact_address(org_id)
      page.clear_contact(org_id)
    end
  end

  def add_contact_info(org_id)
    on(IACUCProtocolOverview).add_contact(org_id)
    on AddressBookLookup do |search|
      search.search
      search.return_random
    end

    on IACUCProtocolOverview do |page|
      @organization_address = page.contact_address(org_id)
    end
  end

end