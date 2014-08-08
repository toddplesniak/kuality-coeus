class SponsorTemplateObject < DataFactory

  include StringFactory, DateFactory, Navigation, DocumentUtilities

  attr_reader :document_id, :status, :description, :template_description, :template_status, :payment_basis,
              :payment_method, :find_sponsor_term, :sponsor_terms_code

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:          random_alphanums,
        template_description: random_alphanums,
        template_status:      '::random::',
        payment_basis:        ['Cost reimbursement', 'Firm fixed price'].sample,

        payment_method:       ['Advanced payment invoice', 'Automatic payment', 'Cost invoice',
                               'Established ACH mechanism for sponsor',
                               'Progress payment invoices', 'SF270/Request for Advance',
                               'Scheduled payment invoices', 'Special Handling--see comments'].sample,
        sponsor_terms_code: rand(1..9) #this value is used in the search to limit results and return the required Type Codes of 1 through 9.

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
    end

    set_sponsor_terms
    on(SponsorTemplate).submit
  end

  # =========
  private
  # =========

  def set_sponsor_terms
    unless @sponsor_terms_code.nil?
      on(SponsorTemplate).sponsor_term_search
      on SponsorTermLookup do |look|
        look.code.fit @sponsor_terms_code
        look.search
        look.select_all_from_this_page #if  1-9 is in Sponsor Term Type Code
        look.return_selected
      end
    else
      puts 'Skipping adding Sponsor Terms.'
    end
  end

    # case 'payment_method'
    #   when 'Fixed price level of effort'
    #     @payment_method = 'Level of effort invoices', 'Special Handling--see comments'
    #   when 'Gift'
    #     @payment_method = 'Gift'
    #   when 'No Payment'
    #     @payment_method = 'No Payment or Billed by Department'
    #   when 'Other'
    #     @payment_method = 'Special Handling--see comments'
    # end

end