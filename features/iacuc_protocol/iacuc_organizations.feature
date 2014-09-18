@IRB @Smoke
Feature: Adding Organizations to IACUC Protocols

  [KCTEST-884] As a researcher I want the ability to add Organizations to a IACUC protocol

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip @KCTEST-884
  Scenario: Add an Organization to the IACUC proposal
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When adds an organization to the IACUC Protocol
    Then the added Organization should be displayed on the IACUC Protocol
    And the id should be on the Organization inquiry page

  @wip @KCTEST-884
  Scenario: Organization cannot be added to the IACUC Protocol without required fields
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When attempts to add an organization to the IACUC Protocol without required fields
    Then errors should appear warning that the field contents are not valid

  @wip @KCTEST-888
  Scenario: Modify an Added Organization's contact information on an IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    And   adds an organization to the IACUC Protocol
    And   changes the contact information on the added Organization
    When  reopens the IACUC Protocol without saving changes
    Then  on the IACUC Protocol the contact information for the added Organization is reverted


