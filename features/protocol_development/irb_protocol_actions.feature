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
  Scenario: Return to PI with amendment updates
    Given the IRB Admin creates a Committee
    And   schedules at least one event for the Committee
    And   submits the Committee
    And   I log in with the IRB Administrator user
    When  I create an IRB Protocol with expedited submissions review type for lead unit '000001'
    And   the IRB Admin submits the Protocol to the Committee for expedited review, with an approval date of last year
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
    And  the IRB Admin assigns reviewers to the Protocol
    And   the IRB Admin assigns the Protocol to reviewers
    Then  the summary approval date should be last year
    And   the expedited date should be yesterday