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
  Scenario: IACUC Protocol missing a required field
    When the IACUC Protocol Creator attempts to create an IACUC Protocol but misses a required field
    Then  an error should appear saying the field is required

  @wip
  Scenario: IACUC add a species to the protocol
    Given the IACUC Administrator creates an IACUC Committee with an area of research
    And   the IACUC Protocol Creator creates an IACUC Protocol
    When  adds a species group to the IACUC Protocol
    Then  the IACUC Protocol status should be Pending/In Progress

  @wip @KC-TA-5417
  Scenario: IACUC Admin deactivates a IACUC Protocol
    Given the IACUC Administrator approves a submitted IACUC Protocol
    When  sends a deactivate request on the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated

  @wip @KC-TA-5417
  Scenario: IACUC Admin lift a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And   places the IACUC Protocol on hold
    When  lifts the hold on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold