Feature: Creating proposals

  As a researcher I want to be able to create valid proposals, so that I can get funding for my research.

  Background: Logged in as admin
      Given   I'm logged in with admin

    Scenario Outline: Attempt to create a proposal while leaving the required text-fields null
      When    I begin a proposal without a <Field Name>
      Then    I should see an error that says "<Field Name> is a required field."

      Scenarios:
        | Field Name          |
        | Proposal Type       |
        | Lead Unit           |
        | Activity Type       |
        | Project Title       |
        | Sponsor Code        |
        | Project Start Date  |
        | Project End Date    |
    @test
    Scenario: Attempt to create a proposal with invalid sponsor code
      When    I begin a proposal with an invalid sponsor code
      Then    I should see an error that says valid sponsor code required
