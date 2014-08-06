class ProposalQuestionsObject < DataFactory

  include StringFactory, DateFactory, Navigation

  attr_reader :document_id, :agree_to_nih_policy, :policy_review_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      agree_to_nih_policy: 'Y',
      policy_review_date:  right_now[:date_w_slashes]
    }

    set_options(defaults.merge(opts))
    requires :document_id
  end

  def create
    navigate
    on Questions do |pq|
      pq.show_proposal_questions
      fill_out pq, :agree_to_nih_policy, :policy_review_date
      pq.save
    end
  end

  # =======
  private
  # =======

  # Nav Aids...

  def navigate
    open_document @doc_type
    on(Proposal).questions unless on_page?(on(Questions).questions_header)
  end

end