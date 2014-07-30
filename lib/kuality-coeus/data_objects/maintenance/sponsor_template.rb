class SponsorTemplateObject < DataFactory

  include StringFactory
  include DateFactory
  include Navigation
  include DocumentUtilities

  attr_reader :document_id, :status, :description, :template_description, :template_status, :payment_basis,
              :payment_method, :find_sponsor_term

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:          random_alphanums,
        template_description: random_alphanums,
        template_status:      '::random::',
        payment_basis:        'Cost reimbursement',
        payment_method:       'Advanced payment invoice'

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

    on(SponsorTemplate).sponsor_term_search
    on SponsorTemplateLookup do |look|
      look.search
      #random row for 'Sponsor Term Id' returns text but results contains 2 trailing spaces on the end that needed to be stripped
      look.select_checkbox(look.return_random_row[1].text.strip).set
      look.return_selected
    end
  end

end