@Proposal
Feature: Project Personnel in Proposal Budget Versions

  User story to be written...

  Background:
    * a User exists with the role: 'Proposal Creator'
    * the Proposal Creator creates a Proposal
    * creates a Budget Version for the Proposal

  Scenario: Proposal and Budget Personnel
    Given various personnel are added to the Proposal
    When  the Proposal Creator syncs the Budget's personnel with the Proposal
    Then  the Budget personnel should match the Proposal personnel
  @test
  Scenario: Personnel info imported from Person record
    Given a User exists with a 'SUMMER EMPLOYEE' appointment type
    When  the Proposal Creator adds the 'SUMMER EMPLOYEE' User to the Budget personnel
    Then  the Budget personnel list shows the SUMMER EMPLOYEE's job code, salary, and appointment type info

  Scenario: Updating a key person's role
    Given the Proposal Creator adds a principal investigator to the Proposal
    And   adds a co-investigator to the Proposal
    When  the Proposal Creator changes the Proposal's co-investigator to a key person
    Then  the Budget's personnel list shows the correct roles

  Scenario: Adding Project Person with Salary and no Inflation Rate
    Given the Proposal Creator adds an employee to the Budget personnel
    When  a Project Person is assigned to Budget period 1, with no salary inflation
    Then  the Project Person's requested salary for the Budget period is as expected

  Scenario: Adding Project Person with Salary and Inflation Rate
    Given the Proposal Creator sets the inflation rate of the Budget's on-campus administrative salaries to 7 percent
    And   adds an employee to the Budget personnel
    When  an 'Administrative Staff - On' person is assigned to Budget period 1
    Then  the Project Person's requested salary for the Budget period is as expected