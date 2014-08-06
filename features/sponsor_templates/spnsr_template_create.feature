Feature: Sponsor Template Creation

  As a user with the Modify Sponsor Template role,
  I want the ability to create Sponsor Template Documents
  that can be linked to KC Awards.

  Background: Establish Sponsor Template user
    Given a User exists with the roles: Modify Sponsor Template, Application Administrator in the 000001 unit
#    * a User exists with the roles: Create Proposal Log, Institutional Proposal Maintainer in the 000001 unit

  @wip @test
  Scenario: Creating a Sponsor Template without Sponsor Template Terms
    When  the Modify Sponsor Template user submits a new Award Sponsor Template without a Sponsor Term
    Then  8 errors display about the missing terms are shown for the edit sponsor template terms tab

  @wip @test
  Scenario: Create a Sponsor Template with all 8 Sponsor Template Terms
    Given I log in with the Modify Sponsor Template user
    When create a Sponsor Template with 8 valid terms
    Then the Sponsor Template status should be 'ENROUTE'
