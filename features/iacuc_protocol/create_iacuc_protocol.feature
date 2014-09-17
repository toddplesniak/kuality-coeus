@IRB @Smoke
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
    When  sends a deactivate request on the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated

  @wip @KC-TA-5417
  Scenario: IACUC Admin lifts a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And   places the IACUC Protocol on hold
    When  lifts the hold on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold

  @wip @KCTEST-881
  Scenario: Verify the expiration date is set after the IACUC Protocol is approved
    Given the IACUC Protocol Creator submits an IACUC Protocol for admin review
    When the IACUC Administrator approves the IACUC Protocol
    Then  the expiration date is set for the Protocol