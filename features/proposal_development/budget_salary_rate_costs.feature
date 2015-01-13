Feature: Employee Salary Rate Costs and Cost Share

  Description TBW

  Background:
    * a User exists with the role: 'Proposal Creator'

  Scenario: Add Employee with a requested Salary
    Given the Proposal Creator creates a 1-month 'Research' activity type Proposal
    And   creates a Budget Version for the Proposal
    And   adds an employee to the Budget personnel
    When  the Proposal Creator assigns a 'Research Staff - On' Person to Period 1, where the charged percentage is lower than the effort
    Then  the Project Person's requested salary for the Budget period is as expected
    And   the Person's Rates show correct costs and cost sharing amounts

  Scenario: Unapplying the Research Rate for an employee
    Given the Proposal Creator creates a Proposal with a 'Research' activity type
    And   creates a Budget Version for the Proposal
    And   adds an employee to the Budget personnel
    And   a 'Research Staff - On' person is assigned to Budget period 1
    And   notes the Budget Period's summary totals
    When  the 'Employee Benefits' 'Research Rate' rate for the 'Research Staff - On' personnel is unapplied
    Then  the Period's Direct Cost is lowered by the expected amount

  Scenario: Unapplying the inflation rate
    Given the Proposal Creator creates a Proposal with a 'Research' activity type
    And   creates a Budget Version for the Proposal
    And   adds an employee to the Budget personnel
    And   an 'Administrative Staff - On' person is assigned to Budget period 1
    And   notes the Budget Period's summary totals
    When  inflation is un-applied for the 'Administrative Staff - On' personnel
    Then  the Period's Direct Cost is lower than before