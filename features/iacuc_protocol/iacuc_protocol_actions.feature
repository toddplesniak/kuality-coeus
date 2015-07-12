@iacuc
Feature: Protocol actions for IACUC Designated Member Review

  TBD

  Background:

  @test
  Scenario: Terminate an IACUC Protocol
    * Users exist with the following roles: IACUC Protocol Creator, Modify IACUC Protocols, IACUC Administrator
    * the IACUC Admin verifies that the KC IACUC 1 committee has future scheduled events
    * the IACUC Protocol Creator submits an IACUC Protocol for designated member review
    Given the IACUC Administrator modifies the IACUC Protocol's submission request
    When  the IACUC Administrator terminates the IACUC Protocol
    Then  the IACUC Protocol submission status should be Terminated

  Scenario: Expire an IACUC Protocol
    When  the IACUC Administrator expires the IACUC Protocol
    Then  the IACUC Protocol status should be Expired

  Scenario: Verify the expiration date is set after the IACUC Protocol is approved
    Then  the expiration date is set for the Protocol

  Scenario: IACUC Admin deactivates an IACUC Protocol
    When  the IACUC Administrator deactivates the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated

  Scenario: IACUC Admin lifts a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator places the IACUC Protocol on hold
    When  the IACUC Administrator lifts the hold placed on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold