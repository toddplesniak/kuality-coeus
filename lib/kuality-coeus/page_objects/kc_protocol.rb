class KCProtocol < BasePage

  document_header_elements
  tab_buttons
  global_buttons
  error_messages

  buttons 'Protocol', 'Personnel', 'Questionnaire', 'Custom Data', 'Special Review',
          'Permissions', 'Notes & Attachments', 'Protocol Actions', 'Medusa', 'Online Review'

  # This removes the methods created in the BasePage, because
  # the Protocol child classes need their own specialized versions...
  undefine :submit, :committee_id

  class << self
    def protocol_page
      # Required Fields
      element(:protocol_type) { |b| b.frm.select(name: 'document.protocolList[0].protocolTypeCode') }
      element(:title) { |b| b.frm.textarea(name: 'document.protocolList[0].title') }
      action(:pi_employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:protocolHelper.personId,fullName:protocolHelper.principalInvestigatorName,unit.unitNumber:protocolHelper.lookupUnitNumber,unit.unitName:protocolHelper.lookupUnitName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
      element(:lead_unit) { |b| b.frm.text_field(name: 'protocolHelper.leadUnitNumber') }
      action(:find_lead_unit) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.Unit!!).(((unitNumber:protocolHelper.leadUnitNumber,unitName:protocolHelper.leadUnitName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }

      # Additional Information
      action(:add_area_of_research) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.irb.ResearchArea!!).((``)).(:;protocolResearchAreas;:).((%true%)).((~~)).anchorAdditionalInformation').click }
      element(:fda_number) { |b| b.frm.text_field(name: 'document.protocolList[0].fdaApplicationNumber') }

      # Other Identifiers
      action(:identifier_type) { |b| b.frm.select_list(name: 'newProtocolReferenceBean.protocolReferenceTypeCode') }
      element(:identifier) { |b| b.frm.text_field(name: 'newProtocolReferenceBean.referenceKey') }
      element(:identifier_application_date) { |b| b.frm.text_field(name: 'newProtocolReferenceBean.applicationDate') }
      element(:identifier_approval_date) { |b| b.frm.text_field(name: 'newProtocolReferenceBean.approvalDate') }
      element(:identifier_comment) { |b| b.frm.textarea(name: 'newProtocolReferenceBean.comments') }
      action(:identifier_add) { |b| b.frm.button(name: 'methodToCall.addProtocolReferenceBean.anchorAdditionalInformation').click }

      # Organizations
      element(:organization_id) { |b| b.frm.text_field(name: 'protocolHelper.newProtocolLocation.organizationId') }
      action(:organization_lookup) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.Organization!!).(((organizationId:protocolHelper.newProtocolLocation.organizationId,contactAddressId:protocolHelper.newProtocolLocation.rolodexId,humanSubAssurance:protocolHelper.newProtocolLocation.organization.humanSubAssurance,organizationName:protocolHelper.newProtocolLocation.organization.organizationName,rolodex.firstName:protocolHelper.newProtocolLocation.organization.rolodex.firstName,rolodex.lastName:protocolHelper.newProtocolLocation.organization.rolodex.lastName,rolodex.addressLine1:protocolHelper.newProtocolLocation.organization.rolodex.addressLine1,rolodex.addressLine2:protocolHelper.newProtocolLocation.organization.rolodex.addressLine2,rolodex.addressLine3:protocolHelper.newProtocolLocation.organization.rolodex.addressLine3,rolodex.city:protocolHelper.newProtocolLocation.organization.rolodex.city,rolodex.state:protocolHelper.newProtocolLocation.organization.rolodex.state))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor21').click }
      action(:organization_type) { |b| b.frm.select_list(name: 'protocolHelper.newProtocolLocation.protocolOrganizationTypeCode') }
      action(:add_organization) { |b| b.frm.button(name: 'methodToCall.addProtocolLocation.anchorOrganizations') }
      #TODO: Create table options so that we can deal with the 'clear contact' and 'delete org' options.

      # Funding Sources
      element(:funding_type) { |b| b.frm.select_list(name: 'protocolHelper.newFundingSource.fundingSourceTypeCode') }
      element(:funding_number) { |b| b.frm.text_field(name: 'protocolHelper.newFundingSource.fundingSourceNumber') }
      action(:funding_number_lookup) { |b| b.frm.button(name: 'methodToCall.performFundingSourceLookup.(!!!!).((())).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).anchor28') }
      action(:add_funding_source) { |b| b.frm.button(name: 'methodToCall.addProtocolFundingSource.anchorFundingSources').click }
    end

  end
end