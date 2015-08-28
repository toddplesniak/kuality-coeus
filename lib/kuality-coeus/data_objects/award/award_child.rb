class AwardChildObject < DataFactory

  include DateFactory, StringFactory

  attr_reader :document_id, :account_id, :transaction_type,
              :key_personnel, :reports

  attr_accessor :document_status, :document_id, :id, :search_key

  def_delegators :@key_personnel, :principal_investigator, :co_investigator,  :co_investigators

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:           'child '+random_alphanums_plus,
        account_id:            'child'+random_alphanums(10),
        key_personnel:         collection('AwardKeyPersonnel'),
        reports:               collection('AwardReports'),
        press:                 'save'
    }

    set_options(defaults.merge(opts))

  end

  def create
    #On award award
    on AwardActions do |create|
      create.expand_all
      create.award_hierarchy
      create.copy_from_parent.when_present.set
      create.create_child
    end
    #now on the child
    on Award do |create|
      create.expand_all
      fill_out create, :description, :account_id, :transaction_type
      create.save
    end

    on Award do |create|
      @document_id = create.header_document_id
      @id = create.award_id.strip
      @search_key = { award_id: @id }
      @document_status = create.header_status
    end
  end

  def view(tab)
    @navigate.call unless on_award?
    unless on(Award).current_tab == tab
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end

  def add_report opts={}
    #IntellectualProperty and TechnicalManagement removed because of a validation bug in CX (https://github.com/rSmart/issues/issues/289).
    opts[:report] ||= %w{Financial Procurement Property ProposalsDue}.sample
    # opts[:report] ||= ['Financial'].sample
    defaults = {award_id: @id, number: (@reports.count_of(opts[:report])+1).to_s}
    view :payment_reports__terms
    @reports.add defaults.merge(opts)
  end

  def submit
    view :award_actions
    # DEBUG.pause(14)
    on AwardActions do |page|
      page.submit_button.wait_until_present
      page.submit
    end
    DEBUG.pause(11)
    on(Confirmation).yes if on(Confirmation).yes_button.exists?
  end

  def update_from_parent id
    @id = id
  end

  def on_award?
    if on(Award).headerinfo_table.exist?
      on(Award).header_award_id==@id
    else
      false
    end
  end

  # ===========
  private
  # ===========


end #AwardChildObject

class AwardChildCollection < CollectionsFactory

  contains AwardChildObject

end