class Meeting < BasePage

  expected_element :workarea_div

  tab_buttons
  global_buttons
  error_messages

  # Meeting Details
  element(:available_to_reviewers) { |b| b.frm.checkbox(name: 'meetingHelper.committeeSchedule.availableToReviewers') }

  # Protocol Submitted

  # Other Actions

  # Attendance

  # Minutes
  element(:minutes_div) { |b| b.frm.div(id: 'tab-Minutes-div') }
  element(:entry_type) { |b| b.frm.select(name: 'meetingHelper.newCommitteeScheduleMinute.minuteEntryTypeCode') }

  # This method returns an Array of Hashes.
  # Each Hash contains Key/Value pairs that correspond
  # to the columns in the Minutes table.
  # Example: { type: 'Protocol Reviewer Comment', protocol: '1407000128',
  #            description: 'text', private: true, final: true,
  #            last_updated_by: 'Stephen Malkmus 07/18/2014 12:48 PM',
  #            created_by: 'AwardDoc Maintainer 07/18/2014 12:47 PM' }
  value(:minute_entries) { |b| array = []; b.minute_entry_rows.
                               each { |row|
                                array << { type: row[1].text,
                                  protocol: row[2].text,
                                  description: me_textarea(row[3]),
                                  private: me_checkbox(row[4]),
                                  final: me_checkbox(row[5]),
                                  last_updated_by: row[6].text,
                                  created_by: row[7].text
                                }
                               }
                               array
                         }

  # Attachments



  # =========
  private
  # =========

  def self.me_textarea(element)
    element.textarea.present? ? element.textarea.value : element.text
  end

  def self.me_checkbox(element)
    element.checkbox.present? ? Transforms::YES_NO[Transforms::CHECK.invert[element.checkbox.set?]] : element.text
  end

  element(:minute_entry_rows) { |b| b.entry_type.present? ? b.frm.table(id: 'minutes-table').rows[2..-1] : b.frm.table(id: 'minutes-table').rows[1..-1] }

end