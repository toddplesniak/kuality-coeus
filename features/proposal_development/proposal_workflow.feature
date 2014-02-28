 Feature: Proposal Workflows and Routing

  As system user with the appropriate roles and permissions, I want the ability to
  take actions against a proposal that will navigate it through various routes
  in workflow.

  Background:
    * Users exist with the following roles: Proposal Creator, OSPApprover

  Scenario: Approval Requests for a Proposal are sent
    Given the Proposal Creator submits a new Proposal into routing
    Then  the Proposal status should be Approval Pending

  Scenario: Approval Request is sent to the Proposal's PI
    Given the Proposal Creator submits a new Proposal into routing
    When  the OSPApprover user approves the Proposal
    Then  the principal investigator can access the Proposal from their action list
    And   the approval buttons appear on the Proposal Summary and Proposal Action pages