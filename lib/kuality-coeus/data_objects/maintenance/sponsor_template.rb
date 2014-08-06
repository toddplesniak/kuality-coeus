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

        payment_method:       'Cost invoice', #['Advanced payment invoice', 'Automatic payment', 'Cost invoice',
                               # 'Established ACH mechanism for sponsor',
                               # 'Progress payment invoices', 'SF270/Request for Advance',
                               # 'Scheduled payment invoices', 'Special Handling--see comments'].sample,
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
    end

    set_sponsor_terms
    on(SponsorTemplate).submit
  end

  # =========
  private
  # =========

  def set_sponsor_terms
    unless @sponsor_terms_code.nil?
      arry = ['Equipment Approval Terms', 'Invention Terms', 'Prior Approval Terms', 'Property Terms', 'Publication Terms', 'Referenced Document Terms', 'Rights In Data Terms', 'Subaward Approval Terms', 'Travel Restrictions Terms']

      on(SponsorTemplate).sponsor_term_search
      on SponsorTermLookup do |look|
        look.code.fit @sponsor_terms_code
        look.search
        #random row for 'Sponsor Term Id' returns text but results contains 2 trailing spaces on the end that needed to be stripped
        look.select_all_from_this_page #if  1-9 is in Sponsor Term Type Code
        look.return_selected
      end
    else
      puts 'Skipping adding Sponsor Terms.'
    end

  end

  # def set_payment_basis_n_method
  #
  #
  #   Fixed price level of effort => Level of effort invoices || Special Handling--see comments
  #   Gift => Gift
  #   No Payment => No Payment or Billed by Department
  #   Other => Special Handling--see comments
  #
  #   'Advanced payment invoice'
  #   'Automatic payment'
  #   'Cost Invoice with Certification'
  #   'Cost invoice '
  #   'DoD Advance Payment Pool'
  #   'Established ACH mechanism for sponsor'
  #   'Fixed price invoice'
  #   'Gift'
  #   'Invoices for fees from members or participants'
  #   'Level of effort invoices'
  #   'No Payment or Billed by Department'
  #   'Progress payment invoices'
  #   'SF270/Request for Advance'
  #   'Scheduled payment invoices'
  #   'Special Handling--see comments'



      # ALL
    # ['Advanced payment invoice', 'Automatic payment', 'Cost Invoice with Certification', 'Cost invoice ',
    #  'DoD Advance Payment Pool', 'Established ACH mechanism for sponsor', 'Fixed price invoice', 'Gift',
    #  'Invoices for fees from members or participants', 'Level of effort invoices',
    #  'No Payment or Billed by Department', 'Progress payment invoices', 'SF270/Request for Advance',
    #  'Scheduled payment invoices', 'Special Handling--see comments'].sample

  #   'Fixed price level of effort'  #only Level of effort & Special Handling
  #   'Gift' #only Gift
  #   'No Payment' #only No Payment ofr billed by department
  #   'Other' #only Special handling
  # end

end