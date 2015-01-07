# This is 5.2x UI... Remove when that's gone...
class Confirmation < BasePage

  global_buttons
  document_header_elements

  value(:message) { |b| b.frm.table.tr.div(align: 'center').text }
  element(:yes_button) { |b| b.frm.button(name: 'methodToCall.processAnswer.button0', class: 'confirm') }
  element(:reason) { |b| b.frm.textarea(name: 'reason') }
  alias_method :recall_reason, :reason
  action(:yes) { |b| b.yes_button.click; b.loading; b.awaiting_doc }
  action(:no) { |b| b.frm.button(class: 'confirm', name: 'methodToCall.processAnswer.button1').click; b.loading; b.awaiting_doc }
  action(:return_to_document) { |b| b.frm.button(class: 'confirm', name: 'methodToCall.processAnswer.button2').click; b.loading }
  alias_method :copy_all_periods, :yes
  alias_method :copy_one_period_only, :no

end #Confirmation

class Dialogs < BasePage

  expected_element :dialog_header

  buttons 'OK', 'Yes', 'No'

end # Dialogs

class ReceiveRequests < Dialogs
  
  element(:dialog_header) { |b| b.header(id: 'PropDev-SubmitPage-ReceiveFutureRequests_headerWrapper') }

end # ReceiveRequests

class Recall < Dialogs

  element(:dialog_header) { raise 'Please define me!' }
  element(:reason) { |b| b.textarea(name: "dialogExplanations['ConfirmRecallDialog']") }

end # Recall

class SendNotifications < Dialogs

  buttons 'Send Notifications'

  element(:dialog_header) { |b| b.header(id: 'Kc-SendNotification-Wizard_headerWrapper') }

  element(:subject) { |b| b.text_field(name: 'notificationHelper.notification.subject') }
  element(:message) { |b| b.textarea(name: 'notificationHelper.notification.message') }

  # Unfortunately this is necessary because it's the only way
  # to know the IP Number when it gets created
  value(:institutional_proposal_number) { |b| b.message.text[/(?<=is )\d+/] }

end # Send Notifications