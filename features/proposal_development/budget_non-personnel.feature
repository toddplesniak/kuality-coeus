Feature: Adding Budget Non-Personnel Costs

  As a researcher, I want to be able to add non-personnel expenses to a period of my budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 2-year, 'Research' Proposal
    * creates a Budget Version for the Proposal

  Scenario: Add a non-personnel line item to period 1
    When the Proposal Creator adds a non-personnel cost with a 'Travel' category type and some cost sharing to the first Budget period
    And the applicable rate is the on-campus 'F & A' 'MTDC' 'MTDC' for the period's fiscal year(s)
    Then the Budget's institutional commitments shows the expected cost sharing value for Period 1