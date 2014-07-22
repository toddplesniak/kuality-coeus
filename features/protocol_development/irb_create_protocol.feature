Feature: Creating IRB Protocols

  As a researcher I want the ability to create a protocol for human subjects

  Background: Establish a Protocol Creator
    * a User exists with the role: 'Protocol Creator'

  Scenario: Attempt to save a proposal with an invalid lead unit
    Given the Protocol Creator user creates a Protocol with an invalid lead unit code
    Then  an error is shown that indicates the lead unit code is invalid

  Scenario: IRB Protocol missing required field
    Given the Protocol Creator creates an IRB Protocol but misses a required field
    Then  an error should appear saying the field is required

  Scenario: Committee Adv Submission Days and IRB Protocol Review
    Given a User exists with the role: 'IRB Administrator'
    And   the IRB Admin submits a Committee with events scheduled before and after its adv submission days setting
    And   the Protocol Creator creates an IRB Protocol in the Committee's home unit
    When  the Protocol is being submitted to that Committee for review
    Then  the earliest available schedule date is based on the Committee's Adv Submission Days value

  Scenario: Exceeding Maximum Protocols
    Given a User exists with the role: 'IRB Administrator'
    And   the IRB Admin submits a Committee that allows a maximum of 1 protocol
    And   the Protocol Creator creates an IRB Protocol in the Committee's home unit
    And   submits the Protocol to the Committee for review
    And   the Protocol Creator creates another IRB Protocol in the Committee's home unit
    When  the second Protocol is submitted to the Committee for review on the same date
    Then  the system warns that the number of protocols exceeds the allowed maximum

  @wip @KRAFDBCK-9927
  Scenario: Return to PI for amendment updates with correct expiration date
    Given a User exists with the role: 'IRB Administrator'
    And log in with the IRB Administrator user
    And I create a IRB Protocol with Expedited Submissions Review Type
    And I submit a Expedited Approval with a date of last year
#  (approval date + 364) leave action date as is (today's date)
    And I add a Create Amendment to the IRB Protocol
#    Then Verify Expiration date is correct
    And I submit an Amendment of type Expedited for review
    When I assign to a reviewer
    Then the Expedited Approval Date should be correct
#    And the Expedited Expiration Date should be correct



#  <create amendment>
#  change nothing
#
#  navigate to protocol actions
#  select amendment + expedited + checkbox <submit>
#  assign to committee + schedule <submit>
#  NOTE: expiration date still shows 6/30/14
#
#  select <return to PI>


#  navigate to amendment protocol tab - expiration date is erased and system says it will generate upon approval (This is wrong, it should retain 6/30/14)
#  navigate to protocol actions
#  select resubmission + expedited + checkbox <submit>
#
#  assign to committee + schedule <submit>
#  assign to reviewer <submit>
#  show expedited approval action
#
#  The approval date and expiration date are not editable and default incorrectly.
#  They should display the approval date of 7/1/13 and expiration date of 6/30/14.
#  Even worse, when you approve the amendment it overwrites the initial protocol
#  existing expiration date with the wrong information that defaulted from the amendment.
#  No admin change can be done for the amendment once approved so incorrect correspondence is generated.