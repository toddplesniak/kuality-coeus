@IACUC
Feature: Creating IACUC Protocols

  As a researcher I want the ability to create a protocol for animal subjects

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  Scenario: Create a IACUC proposal
    When the IACUC Protocol Creator creates an IACUC Protocol
    Then there are no errors on the page
    And  the IACUC Protocol status should be Pending/In Progress

  @KCTEST-34
  Scenario: IACUC Protocol overview is missing a required field
    When the IACUC Protocol Creator attempts to create an IACUC Protocol but misses a required field
    Then  an error should appear saying the field is required


  @wip @KCTEST-912
   Scenario: The system shall allow multiple personnel to be chosen for each add species/groups row.
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When adds two personnel members to the IACUC Protocol
    Then both personnel added to the IACUC Protocol are present

  @wip @KCTEST-928 @KCTEST-929 @KCTEST-930
  Scenario: The Three Principles fields can be edited
    Given the IACUC Protocol Creator creates an IACUC Protocol with the three principles, reduction, refinement, replacement
    And edits the Principles of reduction
    And edits the Principles of refinement
    And edits the Principles of replacement
    Then the three principles should have the edited values after saving the IACUC Protocol