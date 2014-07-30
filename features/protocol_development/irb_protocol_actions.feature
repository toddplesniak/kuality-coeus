@IRB
Feature: IRB Protocol Actions

  Description TBD

  Background:
    * Users exist with the following roles: IRB Administrator, Protocol Creator

  Scenario Outline: Submission Review Type Checklist
    Given the Protocol Creator user creates an IRB Protocol
    When the Protocol is given an '<Type>' Submission Review Type
    Then the <Checklist> Checklist can be filled out

  Examples:
    | Type      | Checklist        |
    | Expedited | Expedited Review |
    | Exempt    | Exempt Studies   |

  @KRAFDBCK-9927
  Scenario: Return to PI with amendment updates
    Given the IRB Admin creates a Committee
    And   schedules at least one event for the Committee
    And   submits the Committee
    And   the IRB Admin submits a Protocol to the Committee for Expedited review, with an approval date of last year
    And   creates an amendment for the Protocol
    And   submits the Protocol to the Committee for review, with:
          | Submission Type | Amendment |
          | Review Type     | Expedited |
    And   notifies the Committee about the Protocol
    And   returns the Protocol to the PI
    And   submits the Protocol to the Committee for review, with:
          | Submission Type | Resubmission |
          | Review Type     | Expedited    |
    And   notifies the Committee about the Protocol
    When  the IRB Admin assigns reviewers to the Protocol
    Then  the Summary Approval Date should be last year
    And   the Expedited Date should be yesterday