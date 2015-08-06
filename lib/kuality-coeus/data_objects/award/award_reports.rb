class AwardReportsObject < DataFactory

  attr_reader :award_id, :report, :type, :frequency,
              :frequency_base, :osp_file_copy,
              :due_date, :recipients, :details,
              # :number is used for field identification in the list
              :number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      type:           '::random::',
      frequency:      '::random::',
      frequency_base: '::random::',
      osp_file_copy:  '::random::',
      details:        collection('ReportTracking')
      #recipients:    collection('ReportRecipients')

    }
    set_options(defaults.merge(opts))
    requires :report, :number
  end

  def create
    on PaymentReportsTerms do |page|
      page.expand_all
      set_report_type
      DEBUG.pause(6)
      set_frequency
      DEBUG.pause(5)
      page.add_frequency_base(@report).pick! @frequency_base
      DEBUG.pause(6)
      page.add_osp_file_copy(@report).pick! @osp_file_copy
      DEBUG.pause(4)
      page.add_due_date(@report).fit @due_date
      DEBUG.pause(5)
      page.add_report(@report)
      page.save
    end
  end

  private

  def set_frequency
    if @frequency == '::random::'
      @frequency = 'None'
      while @frequency == 'None'
        @frequency = on(PaymentReportsTerms).add_frequency(@report).options.map(&:text).sample
      end
    end
    on(PaymentReportsTerms).add_frequency(@report).pick! @frequency
  end

  def set_report_type
    if @type == '::random::'
      @type = 'None'
      while @type == 'None'
        @type = on(PaymentReportsTerms).add_report_type(@report).options.map(&:text).sample
      end
    end
    on(PaymentReportsTerms).add_report_type(@report).pick! @type
  end

end # AwardReportsObject

class AwardReportsCollection < CollectionFactory

  contains AwardReportsObject

  def count_of(report_class)
    self.count{ |r_obj| r_obj.report==report_class }
  end

end