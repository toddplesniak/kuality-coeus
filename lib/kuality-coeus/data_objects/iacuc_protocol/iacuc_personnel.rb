class IACUCPersonnel <  DataFactory

      include StringFactory, Navigation, DateFactory, Protocol

      attr_reader  :protocol_role, :kcperson_id, :full_name, :user_name, :email_address

      def initialize(browser, opts={})
        @browser = browser

        defaults = {
            protocol_role: ['Co-Investigator', 'Study Personnel', 'Correspondents'].sample
        }
        set_options(defaults.merge(opts))
      end

      def create
        view 'Personnel'
        on ProtocolPersonnel do |page|
          page.expand_all
          page.employee_search

          on KcPersonLookup do |lookup|
            lookup.kcperson_id.fit @kcperson_id
            lookup.search
            return_random_person
          end

          page.protocol_role.pick @protocol_role
          page.add_person
        end
      end

      def view(tab)
        raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
        on(IACUCProtocolOverview).send(damballa(tab))
      end

      def return_random_person
        on IACUCProtocolOverview do |page|
          the_row = rand(page.return_value_links.length)
          #need to capture the randomly select person data for validation and future use
          @kcperson_id = page.return_value_links[the_row].parent.parent.td(index: 1).text
          @full_name = page.return_value_links[the_row].parent.parent.td(index: 2).text
          @user_name = page.return_value_links[the_row].parent.parent.td(index: 3).text
          @email_address =  page.return_value_links[the_row].parent.parent.td(index: 4).text

          page.return_value_links[the_row].click
        end
      end
end #IACUCPersonnel