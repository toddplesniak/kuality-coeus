@IRB
Feature: IRB Protocol Actions

  [smoke] - Expedited Reivwe and Exempt Studies checklists can be filled out
  [KRAFDBCK-9927] verify the Summary Approval date and the Expedited date are correct on the IRB Protocol Actions tab after
  setting the approval date back one year and assigning to reviewers after retuning the document to the PI

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
  Scenario: Return to pi with amendment updates has the correct expiration date
    * the IRB Admin creates a Committee
    * schedules at least one event for the Committee
    * submits the Committee
    When the IRB Admin submits a Protocol to the Committee for expedited review, with an approval date of last year
    And  I create an amendment for the Protocol
    And  submits the Protocol for review with:
       | Submission Type | Amendment |
       | Review Type     | Expedited |
    And  notifies the committee about the Protocol
    And  returns the Protocol document to the pi
    And  submits the Protocol for review with:
       | Submission Type | Resubmission |
       | Review Type     | Expedited    |
    And  notifies the committee about the Protocol
    And  assigns reviewers to the Protocol
    And  assigns the protocol action to reviewers
    Then the summary approval date should be last year
    And  the expedited date should be yesterday