class CommitteeMemberObject < DataFactory

  include DateFactory

  attr_reader :document_id, :name, :membership_type, :paid_member, :term_start_date, :term_end_date,
                :roles, :expertise

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        name:            '::random::',
        membership_type: '::random::',
        term_start_date: right_now[:date_w_slashes],
        term_end_date:   hours_from_now(10416)[:date_w_slashes],
        paid_member:     :clear,
        roles:           [{role: '::random::', start_date: right_now[:date_w_slashes], end_date: hours_from_now(10416)[:date_w_slashes]}],
        expertise:       []
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
        @name = page.member_name_pre_add
        page.add_member
      end
    else
      # TODO: Write code for when we know the name
    end
    on Members do |page|
      page.expand_all
      page.membership_type(@name).pick! @membership_type
      page.paid_member(@name).fit @paid_member
      page.term_start_date(@name).fit @term_start_date
      page.term_end_date(@name).fit @term_end_date
      @roles.each { |role|
        page.add_role_type(@name).pick! role[:role]
        page.add_role_start_date(@name).fit role[:start_date]
        page.add_role_end_date(@name).fit role[:end_date]
        page.add_role(@name)
      }
    end
    if @expertise.empty?
      add_expertise
    else
      @expertise.each do |area|
        # TODO: Write this code
      end
    end
    on(Members).save
  end

  private

  def add_expertise(item=nil)
    if item
      # TODO: Write this code
    else
      on Members do |page|
        page.expand_all
        page.lookup_expertise(@name)
      end
      on ResearchAreasLookup do |page|
        page.search
        research_description = page.research_descriptions.sample
        page.check_item(research_description)
        page.return_selected
        @expertise << research_description
      end
    end
  end

end # CommitteeMemberObject

class CommitteeMemberCollection < CollectionsFactory

  contains CommitteeMemberObject

end # CommitteeMemberCollection