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

  new_buttons 'OK', 'Yes', 'No'

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

class BudgetsDialog < Dialogs
  
  element(:dialog_header) { |b| b.header(id: 'PropBudget-BudgetVersions-Dialog_headerWrapper') }
  p_action(:copy) { |name, b| b.target_row(name).button.click; b.link(text: 'Copy').click }

  p_element(:submission_message) { |name, b| b.target_row(name)[0].div(class: 'uif-messageField submissionMessage') }
  
  private
  
  element(:budgets_table) { |b| b.div(title: 'Budget').tbody }
  p_element(:target_row) { |name, b| b.budgets_table.trs.find{|r| r[0].link.text==name } }

end # BudgetsDialog

class CopyThisBudgetVersion < Dialogs
  
  element(:dialog_header) { |b| b.header(id: 'PropDev-BudgetPage-CopyBudgetDialog_headerWrapper') }
  element(:budget_name) { |b| b.text_field(name: 'copyBudgetDto.budgetName') }
  p_element(:copy_periods) { |value, b| b.radio(name: 'copyBudgetDto.allPeriods', value: value).set }

  buttons 'Copy Budget', 'Cancel'

end

class ChangePeriod < Dialogs
  
  element(:dialog_header) { |b| b.header(id: 'PropBudget-PeriodsPage-ChangePeriodDialog_headerWrapper') }

end

class SyncBudgetRates < Dialogs

  element(:dialog_header) { |b| b.header(id: 'PropBudget-ActivityTypeChanged-Dialog_headerWrapper') }

end