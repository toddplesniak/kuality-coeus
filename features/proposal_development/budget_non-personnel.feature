Feature: Budget Non-Personnel Costs

  Description TBW

  Background:
    * a User exists with the role: 'Proposal Creator'

  Scenario: Unapplying rates for a non-personnel cost
    Given the Proposal Creator creates a Proposal with a 'Research' activity type
    And   creates a Budget Version for the Proposal
    And   adds a non-personnel cost to the Budget period
    When  the lab allocation rates for the non-personnel cost are unapplied
    Then  the Period's direct cost is the same as the assigned non-personnel's total base cost