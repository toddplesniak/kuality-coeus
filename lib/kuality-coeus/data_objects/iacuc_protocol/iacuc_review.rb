class IACUCReviewObject < DataFactory

  attr_reader :submission_type, :review_type, :type_qualifier

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        submission_type: '::random::',
        review_type: '::random::',
        type_qualifier: '::random::'
    }
    set_options(defaults.merge(opts))
  end

  def create
    on IACUCSubmitForReview do |page|
      page.expand_all
      fill_out page, :submission_type, :review_type, :type_qualifier
      page.submit
    end
  end

end