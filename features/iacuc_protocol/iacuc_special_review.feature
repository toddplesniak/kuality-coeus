@IACUC
Feature: IACUC Protocol adding special reviews and verify correct error messages display

  Add special reviews to the IACUC Protocol and verify errors display when fields are entered incorrectly

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip @KCTEST-1134
  Scenario: Add special review to the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When IACUC Protocol Creator adds a Special Review to the IACUC Protocol
    Then the first Special Review should be displayed on the IACUC Protocol

  @wip
  Scenario: Edit special review on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    And IACUC Protocol Creator adds a Special Review to the IACUC Protocol
    When IACUC Protocol Creator edits the first Special Review on the IACUC Protocol
    Then the first Special Review should not be displayed on the IACUC Protocol
    And the edited Special Review should display on the IACUC Protocol

  @wip @KCTEST-1140
  Scenario: Verify Special Review error messages display for type, approval status, and invalid dates
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When attempts to add a Special Review to generate error messages
    Then errors should appear warning that the field contents are not valid

  @wip @KCTEST-1140
  Scenario: Verify Special Review error messages display for human subjects when approved with an exemption
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When attempts to add a Special Review for human subjects, status approved, and an exemption
    When attempts to add a Special Review to generate error messages for incorrect date structures
    Then errors should appear warning that the field contents are not valid

  @wip
  Scenario: Verify Special Review error messages display for application date later than approval and expiration dates.
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When attempts to add a Special Review to generate error messages for incorrect date structures
    Then errors should appear warning that the field contents are not valid