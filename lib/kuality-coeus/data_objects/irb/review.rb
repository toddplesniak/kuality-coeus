class ReviewObject < DataFactory

  include StringFactory, Navigation

  attr_reader :reviewer, :document_id, :requested_date, :determination_recommendation,
              :due_date, :protocol_number, :comments, :attachments

  def initialize(browser, opts={})
    @browser = browser

    defaults = {

    }

    set_options(defaults.merge(opts))
  end

  def create

  end

  def add_comment opts={}
    defaults = {}


    @comments << defaults.merge(opts)
  end

  def add_attachment opts={}

  end



  def approve

  end

end # ReviewObject

class ReviewCollection < CollectionFactory

  contains ReviewObject



end