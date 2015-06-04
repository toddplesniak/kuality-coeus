@wip
Feature: Modular Budgets

  As a Researcher I want to be able to submit budgets that will be accepted by the NIH

  Scenario: Syncing budget details to a modular budget
    * a User exists with the role: 'Proposal Creator'
    * the Proposal Creator creates a Proposal with 000340 as the sponsor
    * creates a Budget Version for the Proposal
    #* adds an employee to the Budget personnel
    #* a Project Person is assigned to Budget period 1
    * the Proposal Creator adds a non-personnel cost with a 'Travel' category type and some cost sharing to the first Budget period
    #* adds some Non-Personnel Costs to the first period
    * syncs the modular budget