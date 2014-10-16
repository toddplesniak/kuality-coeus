@IACUC
Feature: Creating IACUC Protocols

  As a researcher I want the ability to create a protocol for animal subjects

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip
  Scenario: Create a IACUC proposal
    When the IACUC Protocol Creator creates an IACUC Protocol
    Then there are no errors on the page
    And  the IACUC Protocol status should be Pending/In Progress

  @wip @KCTEST-34
  Scenario: IACUC Protocol overview is missing a required field
    When the IACUC Protocol Creator attempts to create an IACUC Protocol but misses a required field
    Then  an error should appear saying the field is required

  @wip @KC-TA-5417
  Scenario: IACUC Admin deactivates an IACUC Protocol
    Given the IACUC Administrator approves a submitted IACUC Protocol
    When  the IACUC Administrator deactivates the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated

  @wip @KC-TA-5417
  Scenario: IACUC Admin lifts a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And   places the IACUC Protocol on hold
    When  lifts the hold placed on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold

  @wip @KCTEST-881
  Scenario: Verify the expiration date is set after the IACUC Protocol is approved
    Given the IACUC Protocol Creator submits an IACUC Protocol for admin review
    When the IACUC Administrator approves the IACUC Protocol
    Then  the expiration date is set for the Protocol

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

  @wip @KCIAC-256
  Scenario: do some protocol actions
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And  the IACUC Protocol Creator submits an Amendment for review on the IACUC Protocol
    When the IACUC Administrator approves the amendment
    And  suspends the amendment
    Then the IACUC Protocol submission status should be Suspended