class ParameterMaintenanceDocument < BasePage

  expected_element :parameter_value

  description_field
  global_buttons
  
  element(:parameter_value) { |b| b.frm.textarea(id: 'document.newMaintainableObject.value') }

end