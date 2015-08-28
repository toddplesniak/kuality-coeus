# This is 5.2x UI... Remove when that's gone...
class Confirmation < BasePage

  global_buttons
  document_header_elements

  value(:message) { |b| b.frm.table.tr.div(align: 'center').text }
  element(:yes_button) { |b| b.frm.button(name: 'methodToCall.processAnswer.button0', class: 'confirm') }
  element(:no_button) { |b| b.frm.button(name: 'methodToCall.processAnswer.button1') }

  element(:reason) { |b| b.frm.textarea(name: 'reason') }
  alias_method :recall_reason, :reason
  action(:yes) { |b| b.yes_button.click; b.loading; b.awaiting_doc }
  action(:no) { |b| b.no_button.click; b.loading; b.awaiting_doc }
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

  buttons 'Send Notifications', 'Search for Recipients', 'Add Recipients'

  element(:dialog_header) { |b| b.header(id: 'Kc-SendNotification-Wizard_headerWrapper') }

  element(:subject) { |b| b.text_field(name: 'notificationHelper.notification.subject') }
  element(:message) { |b| b.textarea(name: 'notificationHelper.notification.message') }
  action(:employee_set) {|b| b.label(text: 'Employee').parent.radio.set }
  action(:non_employee_set) {|b| b.label(text: 'Non Employee').parent.radio.set }

  value(:get_search_results) do |b|
      arry = []
      arry_disabled =[]
      b.notification_results_table.checkboxes.each do |box|
        if box.enabled?
          arry << box.name
        else
          arry_disabled << box.name
        end
        # remove duplicate objects disabled with trying to select
        arry = arry - arry_disabled
      end
      arry
    end

  #there are two modals on this page first one is invisible when notification table is displayed
  element(:notification_results_table) { |b| b.div(class: 'modal-dialog modal-lg', index: 1) }
  action(:select_random_checkbox) { |name, b| b.checkbox(name: name).set }

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

class CompleteBudget < Dialogs

  undefine :ok

  element(:dialog_header) { |b| b.header(id: 'PropDev-CompleteBudgetConfirmationDialog_headerWrapper') }
  element(:ready) { |b| b.checkbox(name: 'submitBudgetIndicator') }

  action(:ok) { |b| b.button(data_dismissdialogid: 'PropDev-CompleteBudgetConfirmationDialog').click; b.loading }

end # CompleteBudget

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
  #there are multiple hidden modal dialogues with same tags
  action(:yes_if_visible) { |b| b.buttons(text: 'Yes').each {|b| b.click if b.visible? } }
  element(:div_dialog) { |b| b.div(class: 'modal-dialog modal-sm') }
  element(:dialog_header) { |b| b.header(id: 'PropBudget-ActivityTypeChanged-Dialog_headerWrapper') }

end

class SyncDirectCostLimit < Dialogs

  undefine :yes, :yes_element

  element(:dialog_header) { |b| b.header(id: 'PropBudget-NonPersonnelCosts-SyncToDirectCostLimit_headerWrapper') }

  element(:yes_element) { |b| b.section(id: 'PropBudget-NonPersonnelCosts-SyncToDirectCostLimit').button(text: 'Yes') }
  action(:yes) { |b| b.yes_element.click; b.loading }
end

class SyncModularBudget < Dialogs

  element(:dialog_header) { |b| b.header(id: 'ProposalModularSync_1_headerWrapper') }

end

class SyncPeriodCostLimit < Dialogs

  undefine :yes, :yes_element

  element(:dialog_header) { |b| b.header(id: 'PropBudget-NonPersonnelCosts-SyncToPeriodCostLimit_headerWrapper') }

  element(:yes_element) { |b| b.section(id: 'PropBudget-NonPersonnelCosts-SyncToPeriodCostLimit').button(text: 'Yes') }
  action(:yes) { |b| b.yes_element.click; b.loading }

end

class Participants < Dialogs

  buttons 'Save Changes'

  element(:dialog_header) { |b| b.header(id: 'PropBudget-NonPersonnelCostsPage-EditParticipantSupport-Dialog_headerWrapper') }
  element(:number_of_participants) { |b| b.text_field(name: 'addProjectBudgetLineItemHelper.currentTabBudgetPeriod.numberOfParticipants') }

end

class ConfirmPeriodChanges < Dialogs

  undefine :yes, :yes_element

  element(:dialog_header) { |b| b.header(id: 'PropBudget-ConfirmPeriodChangesDialog_headerWrapper') }

  element(:yes_element) { |b| b.section(id: 'PropBudget-ConfirmPeriodChangesDialog').button(text: 'Yes') }
  action(:yes) { |b| b.yes_element.click; b.loading }
  
end

class ConfirmAutocalculate < Dialogs

  element(:dialog_header) { |b| b.header(id: 'u1839u1b_headerWrapper') }

end

# Appears when a questionnaire has been modified and will affect 
# the current document's already answered questions
# Dialog title is "Please make a selection."
class UpdateQuestionnaire < Dialogs

  undefine :ok
  element(:dialog_header) { |b| b.header(id: 'PropDev-PersonnelPage-UpdateCertification-Dialog_headerWrapper') }
  
  action(:copy) { |b| b.radio(name: 'updateAnswerHeader.updateOption', value: '0').set }
  action(:do_not_copy) { |b| b.radio(name: 'updateAnswerHeader.updateOption', value: '1').set }
  action(:ok) { |b| b.button(id: 'Uif-DialogConfirmButton', text: 'Ok').click; b.loading }

end