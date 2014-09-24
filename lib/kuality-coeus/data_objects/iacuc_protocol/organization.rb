class OrganizationObject < DataFactory

  include StringFactory, Navigation, DateFactory, Protocol

  attr_reader  :organization_id, :organization_type, :clear_contact, :add_contact_info,
               :old_organization_address, :organization_address, :organization_name

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
          return_random_organization
          @organization_id = page.organization_id.value
        end
      else
        page.organization_id.fit @organization_id
      end

      page.organization_type.pick! @organization_type
      page.add_organization
      page.send(@press) unless @press.nil?
    end
  end

  def return_random_organization
    on IACUCProtocolOverview do |page|
    the_row = rand(page.return_value_links.length)
    #need to capture the organization data that will be selected
    @organization_id = page.return_value_links[the_row].parent.parent.td(index: 1).text
    @organization_name = page.return_value_links[the_row].parent.parent.td(index: 2).text
    @organization_address = page.return_value_links[the_row].parent.parent.td(index: 3).text
    @federal_employer_id =  page.return_value_links[the_row].parent.parent.td(index: 4).text
    @congressional_district =  page.return_value_links[the_row].parent.parent.td(index: 5).text
    @contact_address_id =  page.return_value_links[the_row].parent.parent.td(index: 6).text
    page.return_value_links[the_row].click
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