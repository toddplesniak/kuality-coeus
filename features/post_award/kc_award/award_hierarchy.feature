@award
Feature: Award Hierarchy

  Testing Award Hierarchy to ensure funds and

  Background:
    Given Users exist with the following roles: Proposal Creator, Award Modifier

  @awardwip
  Scenario: Award hierarchy child nodes to manage funds for discreet investigators
    Given the Award Modifier creates an Award for 3 years
    When the Award Modifier adds a PI with a responsibility split of 80 and a financial split of 80
    And  adds a COI with a responsibility split of 11 and a financial split of 11
    And  adds the second COI with a responsibility split of 9 and a financial split of 9
    And  adds Terms to the Award
    And  add a Sponsor Contact to the Award
    And  add a Payment & Invoice item to the Award
    And  add a report to the Award
    And  the Award Modifier submits the Award
    And creates a child node that is copied from the parent
#    Given the Award Modifier opens document '49669' for testing
    And removes the co-investigators from the child node
    And submits the child node
    And opens the Award
    And creates a child node that is copied from the parent
    And makes the first co-investigator the principle investigator
    And submits the child node
    And opens the Award
    And creates a child node that is copied from the parent
    And makes the second co-investigator the principle investigator
    And submits the child node

#
#    And adds and 2 co-investigator

#    And add an employee person to be the PI (ex. Joe Tester)
#    And Add an employee person to be a Co-Investigator (ex. Alan Mcafee)
#    And Add another employee to be a Co-Investigator (ex. Burt Shankle)
#    And finalize the award
#    And clear warning for PI
#    And Create a child of the root node for the PI
#    And Create the a child of the root node for “PI Two (Co-investigator of root node -ex. Mcafee will be the PI of this node)
#    And Create the a child of the root node for “PI Three” (Co-investigator of root node -ex. Shankle will be the PI of this node)
#    And now to add the funds…

  Scenario: Award hierarchy child nodes created for every project year.
