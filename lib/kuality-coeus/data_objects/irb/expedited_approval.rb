class ExpeditedApprovalObject < DataFactory

  include StringFactory, Navigation

  attr_reader :approval_date, :expiration_date, :action_date


  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        approval_date: '04/13/2001'
    }
    set_options(defaults.merge(opts))
  end

  def create
    # NOTE: Navigation is accomplished in the parent Protocol object!
    on ExpeditedApproval do |page|
      page.expand_all unless page.approval_date.present?

      page.approval_date.when_present.focus
      #There is a PROBLEM when entering text in Approval Date. A popup appears saying wrong format.
      #entering text into a clear Approval Date field does not produce a popup
      page.approval_date.clear
      page.alert.ok if page.alert.exists?
      page.approval_date.fit @approval_date

      fill_out page, :expiration_date

      page.submit
      page.awaiting_doc
    end
  end

  def enter_risk_level

  end

  def review_comments

  end

end
