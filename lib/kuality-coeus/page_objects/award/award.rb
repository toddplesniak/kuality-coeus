class Award < KCAwards

  description_field

  element(:institutional_proposal_number) { |b| b.frm.text_field(name: 'fundingProposalBean.newFundingProposal.proposalNumber') }
  element(:proposal_merge_type) { |b| b.frm.select(name: 'fundingProposalBean.mergeTypeCode') }
  action(:add_proposal) { |b| b.frm.button(name: 'methodToCall.addFundingProposal.anchorFundingProposals').click; b.loading }

  p_element(:delete_funding_proposal_button) { |match, b| b.target_funding_row(match).button(name: /methodToCall.deleteAwardFundingProposal.line\d+.anchor4/) }
  p_action(:delete_funding_proposal) { |match, b| b.delete_funding_proposal_button(match).click }

  element(:transaction_type) { |b| b.frm.select(name: 'document.awardList[0].awardTransactionTypeCode') }
  value(:award_id) { |b| b.noko.div(id: 'tab-DetailsDates:Institution-div').table[0][1].text.gsub(/\W+$/,'') }
  element(:award_status) { |b| b.frm.select(name: 'document.awardList[0].statusCode') }
  element(:lead_unit_id) { |b| b.frm.text_field(name: 'document.awardList[0].unitNumber') }
  value(:lead_unit_ro) { |b| b.institution_table[0][3].text.strip }
  value(:version) { |b| b.institution_table[1][1].text.strip }
  action(:lookup_lead_unit) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.coeus.common.framework.unit.Unit!!).(((unitNumber:document.awardList[0].unitNumber))).((`document.awardList[0].unitNumber:unitNumber`)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchorDetailsDates').click }
  element(:activity_type) { |b| b.frm.select(name: 'document.awardList[0].activityTypeCode') }
  element(:account_id) { |b| b.frm.text_field(name: 'document.awardList[0].accountNumber') }
  element(:account_type) { |b| b.frm.select(name: 'document.awardList[0].accountTypeCode') }
  element(:award_type) { |b| b.frm.select(name: 'document.awardList[0].awardTypeCode') }
  element(:award_title) { |b| b.frm.textarea(name: 'document.awardList[0].title') }
  element(:sponsor_id) { |b| b.frm.text_field(name: 'document.awardList[0].sponsorCode') }
  element(:prime_sponsor) { |b| b.frm.text_field(name: 'document.awardList[0].primeSponsorCode') }
  action(:lookup_prime_sponsor) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.coeus.common.framework.sponsor.Sponsor!!).(((sponsorCode:document.awardList[0].primeSponsorCode,sponsorName:document.awardList[0].primeSponsor.sponsorName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchorDetailsDates').click }
  element(:cfda_number) { |b| b.frm.text_field(name: 'document.awardList[0].cfdaNumber') }
  element(:nsf_science_code) { |b| b.frm.select(name: 'document.awardList[0].nsfCode') }
  action(:lookup_sponsor) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.coeus.common.framework.sponsor.Sponsor!!).(((sponsorCode:document.awardList[0].sponsorCode,sponsorName:document.awardList[0].sponsor.sponsorName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchorDetailsDates').click }
  element(:project_start_date) { |b| b.frm.text_field(title: 'Project Start Date') }
  element(:project_end_date) { |b| b.frm.text_field(title: '* Project End Date') }
  value(:project_end_date_ro) { |b| b.tm_table[1][1].text }
  # element(:obligation_start_date) { |b| b.frm.text_field(name: /currentFundEffectiveDate/) }
  element(:obligation_start_date) { |b| b.frm.text_field(title: 'Project Start Date', index: 1) }
  element(:obligation_end_date) { |b| b.frm.text_field(title: 'Obligation End Date') }
  element(:anticipated_direct) { |b| b.frm.text_field(title: 'Anticipated Total Direct') }
  value(:anticipated_direct_ro) { |b| b.tm_table[3][1].text }
  element(:anticipated_fna) { |b| b.frm.text_field(title: 'Anticipated Total Indirect') }
  element(:obligated_direct) { |b| b.frm.text_field(title: 'Obligated Total Direct') }
  value(:obligated_direct_ro) { |b| b.tm_table[3][3].text }
  element(:obligated_fna) { |b| b.frm.text_field(title: 'Obligated Total Indirect') }

  element(:add_organization_name) { |b| b.frm.text_field(name: 'approvedSubawardFormHelper.newAwardApprovedSubaward.organizationName') }
  action(:search_organization) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.coeus.common.framework.org.Organization!!).(((organizationName:approvedSubawardFormHelper.newAwardApprovedSubaward.organizationName,organizationId:approvedSubawardFormHelper.newAwardApprovedSubaward.organizationId))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchorSubawards').click }
  element(:add_subaward_amount) { |b| b.frm.text_field(name: 'approvedSubawardFormHelper.newAwardApprovedSubaward.amount') }
  action(:add_subaward) { |b| b.frm.button(name: 'methodToCall.addApprovedSubaward.anchorSubawards').click }
  element(:approved_subaward_table) { |b| b.frm.table(summary: 'Approved Subaward') }

  element(:tm_table) { |b| b.noko.div(id: 'tab-DetailsDates:TimeMoney-div').table }
  element(:institution_table) { |b| b.frm.div(id: 'tab-DetailsDates:Institution-div').table }

  element(:current_funding_proposals_table) { |b| b.frm.table(id: 'currentFundingProposalsTable') }

  element(:error_summary) { |b| b.frm.div(class: 'error') }

  value(:exception_errors) { |b| b.noko.divs(align: 'left').map{|d| d.text} }

  element(:error_message) { |b| b.frm.div(text: 'Error Message') }

  private

  p_action(:target_funding_row) { |match, b| b.current_funding_proposals_table.row(text: /#{Regexp.escape(match)}/) }

end