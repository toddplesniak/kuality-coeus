@IRB
Feature: IRB Protocol Actions

  TBD

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

  Scenario:

  @wip @KRAFDBCK-9927
  Scenario: Return to PI with amendment updates has the correct expiration date
    * the IRB Admin creates a Committee
    * schedules at least one event for the Committee
    * submits the Committee
    When the IRB Admin submits a Protocol to the Committee for Expedited review, with an approval date of last year
    And  I add a Create Amendment to the IRB Protocol
    And  on the Protocol Actions I Submit for Review with:
       | Submission Type | Amendment |
       | Review Type     | Expedited |
    And  I Notify the Committee on the Protocol Action
    And  I return the Protocol Actions to the PI
    And  on the Protocol Actions I Submit for Review with:
       | Submission Type | Resubmission |
       | Review Type     | Expedited    |
    And  I Notify the Committee on the Protocol Action
    And  I assigns reviewers to the Protocol
    And  I assign the Protocol Action to reviewers
    Then the Summary Approval Date should be last year
    And  the Expedited Date should be yesterday