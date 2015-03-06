Feature: Editing a Budget's Non-Personnel Costs

  As a researcher, I want to be able to quickly sync my period Equipment line items
  with the Period Direct Cost Limit, for every period of the Budget.

  Scenario:
    Given Users exist with the following roles: Proposal Creator
    And   the Proposal Creator creates a 5-year, 'Research' Proposal
    And   creates a Budget Version for the Proposal
    And   adds a direct cost limit to all of the Budget's periods
    And   adds a non-personnel cost with an 'Equipment' category type to all Budget Periods