class CommitteeScheduleObject < DataFactory

  include DateFactory
  include StringFactory

  attr_reader :document_id, :date, :start_time, :meridian,
              :place, :recurrence, :recurrence_settings, :status,
              :deadline, :day_of_week

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        date:       next_monday[:date_w_slashes],
        start_time: "#{rand(12)+1}:#{rand(60)}",
        meridian:   %w{AM PM}.sample,
        place:      random_alphanums_plus(20),
        recurrence: 'Never'
    }
    set_options(defaults.merge(opts))
    requires :document_id
  end

  def create
    on CommitteeSchedule do |page|
      fill_out :date, :start_time, :place
      page.meridian @meridian
      page.recurrence @recurrence
    end
  end

  private

  def recurrence_parameters
    {
        Daily:   {selection: 'XDAY', },
        Weekly:  {},
        Monthly: {},
        Yearly:  {}
    }
  end

end # CommitteeScheduleObject

class CommitteeScheduleCollection < CollectionsFactory

  contains CommitteeScheduleObject

end