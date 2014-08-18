class ProtocolOverview < KCProtocol

  expected_element :workarea_div

  description_field
  tiny_buttons
  protocol_page

  # Document Overview
  element(:organization_doc_number) { |b| b.frm.text_field(name: 'document.documentHeader.organizationDocumentNumber') }

  # Status and Dates
  #TODO: Capture status and dates table.

  # Additional Information
  element(:reference_id1) { |b| b.frm.text_field(name: 'document.protocolList[0].referenceNumber1') }
  element(:reference_id2) { |b| b.frm.text_field(name: 'document.protocolList[0].referenceNumber2') }
  element(:summary) { |b| b.frm.textarea(name: 'document.protocolList[0].description') }

  # Participant Types
  element(:participant_type) { |b| b.frm.select_list(name: 'protocolHelper.newProtocolParticipant.participantTypeCode') }
  element(:participant_count) { |b| b.frm.text_field(name: 'protocolHelper.newProtocolParticipant.participantCount') }
  action(:participant_add) { |b| b.frm.button(name: 'methodToCall.addProtocolParticipant.anchorParticipantTypes').click }
  #TODO: Create table options to maintain the partipant types and counts. Also so that counts can be updated.

end