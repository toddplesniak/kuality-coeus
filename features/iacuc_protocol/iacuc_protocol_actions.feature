@IACUC
Feature: Protocol actions for IACUC

  [KCIAC-256] Create an amendment then suspend that amendment for an IACUC Protocol

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip @KCIAC-256
  Scenario: Suspend a IACUC Protocol with an amendment
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And   the IACUC Protocol Creator submits an Amendment for review on the IACUC Protocol
    When  the IACUC Administrator approves the amendment for the IACUC Protocol
    And  submits a suspend action on the iacuc protocol
    Then  the IACUC Protocol submission status should be Suspended

  @wip @KCIAC-256
  Scenario: Terminate an IACUC Protocol
    When the IACUC Administrator approves a submitted IACUC Protocol
    And  submits a terminate action on the iacuc protocol
    Then the IACUC Protocol submission status should be Terminated

  @wip @KCIAC-256
  Scenario: Expire an IACUC Protocol
    When the IACUC Administrator approves a submitted IACUC Protocol
    And  submits a expire action on the iacuc protocol
    Then the IACUC Protocol status should be Expired

