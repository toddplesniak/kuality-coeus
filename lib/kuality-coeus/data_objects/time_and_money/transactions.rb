class TransactionObject < DataFactory

  include StringFactory

  attr_reader :comments, :source_award, :destination_award,
              :obligated_change, :anticipated_change, :number

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        comments: random_alphanums_plus,
        source_award: 'External',
        obligated_direct_change: random_dollar_value(111),
        anticipated_direct_change: random_dollar_value(111),
        obligated_fna_change: random_dollar_value(111),
        anticipated_fna_change: random_dollar_value(111)
    }
    set_options(defaults.merge(opts))
    requires :destination_award
  end

  def create
    on TimeAndMoney do |page|
      if page.edit_button.present?
        # We're on a T&M document in final status
        page.edit
        # So now a new doc gets created, so
        # we need to update the DataObject info
        @id = page.header_document_id
        @status = page.header_status
      end
      page.expand_all
      page.comments.fit @comments
      page.source_award.pick! @source_award
      page.destination_award.pick! @destination_award

      page.obligated_direct_change.fit @obligated_change
      page.anticipated_direct_change.fit @anticipated_change

      page.obligated_fna_change.fit @obligated_change
      page.anticipated_fna_change.fit @anticipated_change

      # page.obligated_change.fit trans[:obligated_change]
      # page.anticipated_change.fit trans[:anticipated_change]
      #
      # page.obligated_change.fit trans[:obligated_change]
      # page.anticipated_change.fit trans[:anticipated_change]

      page.add_transaction
      page.save
      @number=page.last_transaction_id
    end
  end

  def edit opts={}

  end

end # TransactionObject

class TransactionsCollection < CollectionFactory

  contains TransactionObject

end # TransactionsCollection