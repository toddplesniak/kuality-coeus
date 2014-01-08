Feature: Creating Proposal Logs

  As a researcher I want the ability to create a Proposal Log document
  so that my institution can create an Institutional Proposal record apart
  from the KC Proposal Development and Budget modules.

  Background:
    Given a User exists with the role: 'Create Proposal Log'
    And   I log in with the Create Proposal Log user

  Scenario: Create a new Proposal Log Document
    When  I create a Proposal Log
    Then  the status of the Proposal Log should be INITIATED
    And   the Proposal Log status should be Pending