Feature: Editing a Budget's Non-Personnel Costs

  As a researcher, I want to be able to quickly sync my period Equipment line items
  with the Period Direct Cost Limit, for every period of the Budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 5-year, 'Research' Proposal
    * creates a Budget Version for the Proposal

  Scenario: Syncing non-personnel line items in all periods with direct cost limits
    Given the Proposal Creator adds a direct cost limit to all of the Budget's periods
    And   adds a non-personnel cost to each Budget Period that exceeds the direct cost limit
    When  the non-personnel cost is synced with the direct cost limit for each period
    Then  the direct cost is equal to the direct cost limit in all periods
  #RESOPS-324
  @wip
  Scenario: Syncing non-personnel line items in all periods with total cost limits
    Given the Proposal Creator adds a total cost limit of $1000000 to all of the Budget's periods
    And   adds a non-personnel item with a total base cost of $1100000 to each Budget Period
    And   adds an NPC with a base cost of $999000 to the 1st period and copies it to the others
    When  the first non-personnel cost is synced with the total cost limit for each period
    Then  the Period's total sponsor cost should equal the cost limit
  @system_failure
  Scenario: Removing F&A charges, applying to all Budget periods
    Given the Proposal Creator adds a non-personnel cost with a narrow date range and a 'Travel' category type to the first Budget period
    When  the F & A rates for the non-personnel item are unapplied for all periods
    Then  the Budget's F&A costs are zero for all periods
    And   the Budget's unrecovered F&A amounts are as expected for all periods
  @system_failure
  Scenario: Deleting line items from later periods
    Given the Proposal Creator adds some Non-Personnel Costs to the first period
    And   adds an employee to the Budget personnel
    And   a Project Person is assigned to Budget period 1
    And   auto-calculates the budget periods
    And   edits the total cost and cost sharing amounts for the Non-Personnel Cost in period 2
    When  the Non-Personnel Cost item in periods 3 through 5 is deleted
    Then  the Budget's Periods & Totals should be as expected