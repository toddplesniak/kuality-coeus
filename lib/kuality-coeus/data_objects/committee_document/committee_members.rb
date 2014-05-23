class CommitteeMemberObject < DataFactory

  include DateFactory

  attr_reader :document_id, :name, :membership_type, :paid_member, :term_start_date, :term_end_date,
                :roles, :research_areas

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        name: '::random::',
        term_start_date: now[:date_w_slashes],
        term_end_date:   next_month[:date_w_slashes],
        paid_member:     :clear,
        roles:           [{role: '::random::', start_date: right_now[:date_w_slashes], end_date: next_month[:date_w_slashes]}],
        research_areas:  []
    }

    set_options(defaults.merge(opts))
    requires :document_id
  end

  def create
    # Navigation done by CommitteeDocument object
    # TODO: Support non-employee searching
    on(Members).employee_search
    if @name=='::random::'
      on PersonLookup do |page|
        letter = %w{a r e o n}.sample
        page.first_name.set "*#{letter}*"
        page.search
        page.return_random
      end
      on Members do |page|
        @name = page
      end
    else
      # TODO: Write code for when we know the name
    end
  end



end # CommitteeMemberObject

class CommitteeMemberCollection < CollectionsFactory

  contains CommitteeMemberObject

end # CommitteeMemberCollection