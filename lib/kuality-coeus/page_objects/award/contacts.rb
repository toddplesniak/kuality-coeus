class AwardContacts < KCAwards

  combined_credit_splits

  expected_element :close_button

  # Key Personnel
  action(:employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.coeus.common.framework.person.KcPerson!!).(((personId:projectPersonnelBean.personId))).((`projectPersonnelBean.newProjectPerson.person.fullName:lastName`)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchorKeyPersonnelandCreditSplit').click }
  action(:non_employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.coeus.common.framework.rolodex.NonOrganizationalRolodex!!).(((rolodexId:projectPersonnelBean.rolodexId))).((`projectPersonnelBean.rolodexId:rolodexId,projectPersonnelBean.newProjectPerson.rolodex.fullName:lastName`)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchorKeyPersonnelandCreditSplit').click }
  element(:kp_employee_user_name) { |b| b.frm.text_field(name: 'projectPersonnelBean.newProjectPerson.person.fullName') }
  value(:kp_employee_full_name) { |b| b.frm.div(id: 'per.fullName.div').text }
  element(:kp_non_employee_id) { |b| b.frm.text_field(name: 'projectPersonnelBean.newProjectPerson.rolodex.fullName') }
  element(:kp_project_role) { |b| b.frm.select(name: 'projectPersonnelBean.contactRoleCode') }
  element(:key_person_role) { |b| b.frm.text_field(name: 'projectPersonnelBean.newAwardContact.keyPersonRole') }
  action(:add_key_person) { |b| b.frm.button(name: 'methodToCall.addProjectPerson').click; b.loading }

  p_element(:project_role) { |name, b| b.key_personnel_table.row(text: /#{Regexp.escape(name)}/).select(name: /contactRoleCode/) }
  value(:key_personnel) { |b| b.key_personnel_table.hiddens(name: /award_person.identifier_\d+/).map { |hid| hid.parent.text.strip } }

  value(:get_full_name) {|b| b.frm.div(id: 'per.fullName.div').text.strip }

  p_element(:person_row) { |full_name, b| b.frm.table(id: 'contacts-table').div(text: /#{full_name}/).button(title: 'Direct Inquiry').parent.parent.parent }
  p_action(:delete_person) { |full_name, b| b.person_row(full_name).button(name: /^methodToCall\.deleteProjectPerson\.line/).click; b.loading }

  p_element(:edit_project_role) { |full_name, b| b.person_row(full_name).select(id: /contactRoleCode/) }

  # p_action(:delete_people_with_role) {|role, b| b.frm.table(id: 'contacts-table').select_lists.each { |list| list.parent.parent.parent.button(name: /^methodToCall\.deleteProjectPerson\.line/).click if list.value == role  }; b.loading }

  p_action(:delete_person_with_role) { |role, b| b.frm.table(id: 'contacts-table').select_list(value: role).parent.parent.parent.button(name: /^methodToCall\.deleteProjectPerson\.line/).click; b.loading }

  #gathers people in a hash {[name: 'bob', role: 'COI'],}
  value(:get_key_people) do |b|
    peoples = []
    b.frm.table(id: 'contacts-table').trs.each do |row|
      ( peoples <<  { name: row.td.text.strip, role: row.select.selected_options.map(&:text).join } ) if row.button(name: /^methodToCall\.deleteProjectPerson\.line/).exists?
    end
    peoples
  end





  #name
    # months = Hash.new { |hash, key| hash[key] = Array.new(5) }
  # b.frm.table(id: 'contacts-table').trs.each { |row| puts row.td.text if row.button(name: /^methodToCall.deleteProjectPerson.line/).exists? }







  # Person Details

  # Unit Details
  action(:add_lead_unit) { |name, b| b.person_units(name).checkbox(title: 'Lead Unit').set }
  action(:add_unit_number) { |name, b| b.person_units(name).text_field(title: 'Unit Number') }
  action(:add_unit) { |name, b| b.person_units(name).button(title: 'Add Contact').click }
  # This returns an array of hashes, like so:
  # [{:name=>"Unit1 Name", :number=>"Unit1 Number"}, {:name=>"Unit2 Name", :number=>"Unit2 Number"}]
  action(:units) { |name, b| b.person_units(name).to_a[2..-1].map{ |row| {name: row[2].strip, number: row[3].strip } } }

  p_element(:unit_details_errors_div) { |name, p| p.target_key_person_div(name).div(class: 'left-errmsg-tab').div }
  p_value(:unit_details_errors) { |name, p| p.unit_details_errors_div(name).divs.collect { |div| div.text } }

  #Note: used to validate that the buttons exist at all...
  element(:lead_unit_radio_button) { |b| b.frm.radio(name: 'selectedLeadUnit') }
  p_element(:lead_unit_radio) { |name, unit, b| b.person_unit_row(name, unit).radio(name: 'selectedLeadUnit') }
  p_action(:delete_unit) { |name, unit, b| b.person_unit_row(name, unit).button(name: /^methodToCall\.deleteProjectPersonUnit/).click }
  p_element(:delete_unit_element) { |name, unit, b| b.person_unit_row(name, unit).button(name: /^methodToCall\.deleteProjectPersonUnit/) }
  action(:unit_name) { |name, unit, b| b.person_unit_row(name, unit)[2].text.strip }

  action(:delete_unit_row) { |b| b.frm.button(name: /methodToCall.deleteProjectPersonUnit/).click }
  # This button is only present in the context of a Key Person...
  action(:add_unit_details) { |name, p| p.person_units(name).button(title: 'Add Unit Details').click }

  # Unit Contacts
  element(:unit_employee_user_name) { |b| b.frm.text_field(name: 'unitContactsBean.newAwardContact.fullName') }
  element(:unit_project_role) { |b| b.frm.select(name: 'unitContactsBean.unitContact.unitAdministratorTypeCode') }
  action(:add_unit_contact) { |b| b.frm.button(name: 'unitContactsBean.unitContact.unitAdministratorTypeCode').click; b.loading }

  # Sponsor Contacts
  element(:sponsor_non_employee_id) { |b| b.frm.text_field(name: 'sponsorContactsBean.newAwardContact.rolodex.fullName') }
  value(:org_name) { |b| b.frm.div(id: 'org.fullName.div').text }
  element(:sponsor_project_role) { |b| b.frm.select(name: 'sponsorContactsBean.contactRoleCode') }
  action(:search_sponsor_contact) { |b| b.sponsor_non_employee_id.parent.button(title: 'Search ').click; b.loading }
  action(:add_sponsor_contact) { |b| b.frm.button(name: 'methodToCall.addSponsorContact').click; b.loading }

  # Close button element (used to force waiting for page load)
  element(:close_button) { |b| b.frm.button(title: 'close') }

  # Combined Credit Split
  element(:cs_recognition) {|b| b.frm.text_field(id: 'document.awardList[0].projectPersons[0].creditSplits[0].credit') }
  element(:cs_responsibility) {|b| b.frm.text_field(id: 'document.awardList[0].projectPersons[0].creditSplits[1].credit') }
  element(:cs_space) {|b| b.frm.text_field(id: 'document.awardList[0].projectPersons[0].creditSplits[2].credit') }
  element(:cs_financial) {|b| b.frm.text_field(id: 'document.awardList[0].projectPersons[0].creditSplits[3].credit') }

  element(:cs_unit_recognition) { |b| b.frm.text_field(id: 'document.awardList[0].projectPersons[0].units[0].creditSplits[0].credit') }
  element(:cs_unit_responsibility) { |b| b.frm.text_field(id: 'document.awardList[0].projectPersons[0].units[0].creditSplits[1].credit') }

  action(:recalculate) { |b| b.frm.button(name: 'methodToCall.recalculateCreditSplit').click; b.loading}

  # p_element(:responsibility) { |full_name, b| b.frm.div(id: "#{full_name.gsub(' ', '  ')}_Responsibility_1").text_field }
  # p_element(:financial) { |full_name, b| b.frm.div(id: "#{full_name.gsub(' ', '  ')}_Financial_2").text_field }

  # p_element(:unit_responsibility) { |index, b| b.frm.text_field(id: "document.awardList[0].projectPersons[#{index}].units[0].creditSplits[0].credit") }
  # p_element(:unit_financial) { |index, b| b.frm.text_field(id: "document.awardList[0].projectPersons[#{index}].units[0].creditSplits[1].credit") }
  element(:no_splits) { |b| b.frm.td(text: 'Key Personnel and Credit Split (0)') }
  value(:people_present) { |b| arry=[]; b.frm.div(id: 'tab-ProjectPersonnel:CombinedCreditSplit-div').table.tbody.tds(class: 'tab-subhead').each {|td| arry << td.text}; arry }

  p_element(:person_has_unit) {|full_name, b| b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").button(name: /^methodToCall\.deleteProjectPersonUnit\.personIndex/)   }
  p_action(:unit_lookup_for_person) {|full_name, b| b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").button(title: 'Search ').click }
  p_action(:add_unit_for_person) {|full_name, b| b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").button(title: 'Add Contact').click }
  # p_value(:get_unit_numbers_for_person) {|full_name, b| arry=[]; b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").tbody(index: 2).trs.each {|row| arry << row.td(index: 1).text.strip }; arry.uniq! }

  #TODO: HTML tags to remove having to use the delete button to find the units on a personnel memeber
  p_element(:person_units_delete_buttons) {|full_name, b| b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").buttons(name: /^methodToCall\.deleteProjectPersonUnit\.personIndex/)   }
  p_value(:get_unit_numbers_for_person) {|full_name, b| arry=[]; b.person_units_delete_buttons(full_name).each {|btn| arry << btn.parent.parent.parent.td(index: 1).text.strip }; arry.uniq! }
  p_value(:person_div_text) {|full_name, b| arry=[]; b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").table(summary: 'Project Personnel Units').tbody(index: 2).trs.each {|row| arry << row.td(index: 1).text.strip }; arry }
  p_value(:person_div_text_with_radio) {|full_name, b| arry=[]; b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").table(summary: 'Project Personnel Units').tbody(index: 2).trs.each {|row| arry << row.td(index: 2).text.strip }; arry }
  p_value(:person_div_text_straight) {|full_name, b| b.frm.div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").table(summary: 'Project Personnel Units').tbody(index: 2).trs.each {|row| puts row.td(index: 1).text.strip } }

  p_value(:unit_details_with_radio_buttons) { |full_name,b | b.table(summary: 'Key Personnel').div(id: "tab-#{full_name.gsub(' ', '')}:UnitDetails-div").radio(name: 'selectedLeadUnit').exists? }
  # ===========
  private
  # ===========

  p_element(:target_key_person_div) { |name, b| b.frm.div(id: "tab-#{nsp(name)}:UnitDetails-div") }
  p_element(:person_units) { |name, b| b.target_key_person_div(name).table(summary: 'Project Personnel Units') }
  p_element(:person_unit_row) { |name, unit, b| b.person_units(name).row(text: /#{unit}/) }
  element(:key_personnel_table) { |b| b.frm.table(id: 'contacts-table') }

  element(:credit_split_div_table) { |b| b.frm.div(id: 'tab-ProjectPersonnel:CombinedCreditSplit-div').table }

  action(:target_unit_row) do |full_name, unit_number, p|
    trows = p.credit_split_div_table.rows
    index = trows.find_index { |row| row.text=~/#{Regexp.escape(full_name)}/ }
    trows[index..-1].find { |row| row.text=~/#{unit_number}/ }
  end

end