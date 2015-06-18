@proposal
Feature: Compliance Validation

  As a researcher I want to know if there are problems
  with my proposal's Special Review items so that I can fix them
  before I submit the proposal
  This is failing, see https://jira.kuali.org/browse/KRAFDBCK-12286
  @system_failure
  Scenario: The application date must be prior to the approval date
    Given a User exists with the role: 'Proposal Creator'
    And   the Proposal Creator creates a Proposal
    When  a compliance item is added to the Proposal with an approval date earlier than the application date
    Then  an error should appear that says the approval should occur later than the application