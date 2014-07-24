class ReviewObject < DataFactory

  include StringFactory, DateFactory

  attr_reader :reviewer, :requested_date, :determination_recommendation,
              :type, :due_date, :attachments, :comments

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        requested_date: right_now[:date_w_slashes],
        comments: [],
        attachments: []
    }

    set_options(defaults.merge(opts))
    requires :reviewer, :due_date
  end

  def create

  end

  def add_comment opts={}
    defaults = {
        comment: random_multiline(200, 10),
        private: 'No',
        final:   'No'
    }
    options = defaults.merge(opts)
    # Navigation done by the Protocol Object and/or step definition
    on OnlineReview do |page|
      page.expand_all
      page.new_review_comment(@reviewer).set options[:comment]
      page.add_comment(@reviewer)
      page.save_review_of(@reviewer)
    end
    @comments << options
  end

  def add_attachment opts={}

  end

  def approve
    on(OnlineReview).approve_review_of @reviewer
  end

  def accept_comments
    on(OnlineReview).accept_review_comments_of @reviewer
  end

  def mark_comments_private
    on(OnlineReview).expand_all
    @comments.each do |comment|
      comment[:private]= 'Yes'
      on(OnlineReview).comment_final(comment[:comment]).fit comment[:private]
    end
    on(OnlineReview).save_review_of @reviewer
  end

  def mark_comments_final
    on(OnlineReview).expand_all
    @comments.each do |comment|
      comment[:final]= 'Yes'
      on(OnlineReview).comment_final(comment[:comment]).fit comment[:final]
    end
    on(OnlineReview).save_review_of @reviewer
  end

end # ReviewObject

class ReviewCollection < CollectionFactory

  contains ReviewObject

  def review_by(reviewer)
    self.find { |review| review.reviewer==reviewer }
  end

end