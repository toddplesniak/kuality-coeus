class SponsorTemplateObject < DataFactory

  include StringFactory
  include DateFactory
  include Navigation
  include DocumentUtilities

  attr_reader :document_id, :status, :description, :template_description, :template_status, :payment_basis,
              :payment_method, :find_sponsor_term, :sponsor_terms_code

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:          random_alphanums,
        template_description: random_alphanums,
        template_status:      '::random::',
        payment_basis:        '::random::', #'Cost reimbursement',
        payment_method:       '::random::', #'Advanced payment invoice',
        sponsor_terms_code: rand(1..9) #this value is used in the search to limit results and return Type Code of 1 to 9.

    }
    set_options(defaults.merge(opts))
  end

  def create
    visit(Maintenance).sponsor_template

    on(Lookups).create_new

    on SponsorTemplate do |add|
      @document_id=add.document_id
      @status=add.document_status
      add.expand_all
      fill_out add, :description, :template_description, :template_status, :payment_basis, :payment_method
      set_sponsor_terms
      add.submit
    end

  end

  # =========
  private
  # =========

  def set_sponsor_terms
    if @sponsor_terms_code > 0
      arry = ['Equipment Approval Terms', 'Invention Terms', 'Prior Approval Terms', 'Property Terms', 'Publication Terms', 'Referenced Document Terms', 'Rights In Data Terms', 'Subaward Approval Terms', 'Travel Restrictions Terms']

      on(SponsorTemplate).sponsor_term_search
      on SponsorTermLookup do |look|
        puts sponsor_terms_code.inspect #debug
        puts 'was the code' #debug

        look.code.fit @sponsor_terms_code

        puts 'code value is?'
        puts look.code.value

        look.search
        #random row for 'Sponsor Term Id' returns text but results contains 2 trailing spaces on the end that needed to be stripped
        # look.select_checkbox(look.return_random_row[1].text.strip).set
        sleep 10 #debug
        look.select_all_from_this_page #if  1-9 is in Sponsor Term Type Code
        look.return_selected
      end
    else
      puts 'Skipping adding Sponsor Terms.'
    end

  end

end