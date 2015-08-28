@award
Feature: Award Hierarchy

  Testing Award Hierarchy to ensure funds and

  Background:
    Given Users exist with the following roles: Proposal Creator, Award Modifier, Time And Money Modifier

  @awardwip
  Scenario: Award hierarchy child nodes to manage funds for discreet investigators
    Given the Award Modifier creates an Award for 3 years
    When the Award Modifier adds a PI to the award
    And  adds a COI to the award
    And  adds a COI to the award
    And  all key personnel on the award have at least one unit
    And  sets credit splits of the the PI to 80 COI to 11 and second COI to 9
    And  adds Terms to the Award
    And  add a Sponsor Contact to the Award
    And  add a Payment & Invoice item to the Award
    And  add a report to the Award
    And  the Award Modifier submits the Award
    And  creates a child node that is copied from the parent
    And  submits the first child with the first co-investigator as the only contact
    And  opens the Award
    And  creates a child node that is copied from the parent
    And  submits a second child with the second co-investigator as the only contact
    And  opens the Award
    And  creates a child node that is copied from the parent
    And  submits the third child with the principal investigator as the only contact
    And  the Time And Money Modifier initializes the Award's Time And Money document
    And  add a T&M transaction from External to the Award, with obligated and anticipated amounts of 900
    And  add a T&M transaction to the first child from External to the Award, with obligated and anticipated amounts of 100
    And  add a T&M transaction to the second child from External to the Award, with obligated and anticipated amounts of 100
    And  add a T&M transaction to the third child from External to the Award, with obligated and anticipated amounts of 100


#  Click the Time & Money button to open the document
#  Click Edit
#  Transaction Type = Allotment (increment)
#  Comment (example Add initial funds to all child nodes)
#  Transactions > show
#  First transaction- fund root with anticipated
#  Comment: ex. Anticipated funds
#  Source = External
#  Destination + *-00001 (root)
#  Anticipated Direct Change = 900,000
#  Anticipated F&A Change = 450,000
#  Add
#
#  Second transaction- fund child node -00002
#  Comment: ex. Distribution for Tester
#  Source = *external
#  Destination + *-00002 (Tester’s node)
#  Obligated Direct Change = 100,000
#  Obligated F&A Change = 50,000
#  Add
#  Third transaction- fund child node -00003
#  Comment: ex. Distribution for McAfee
#  Source = *external
#  Destination + *-00003 (McAfee’s node)
#  Obligated Direct Change = 100,000
#  Obligated F&A Change = 50,000
#  Add
#
#  Fourth transaction- fund child node -00004
#  Comment: ex. Distribution for Shankle
#  Source = *external
#  Destination + *-00004 (Shankle’s node)
#  Obligated Direct Change = 100,000
#  Obligated F&A Change = 50,000
#  Add
#  Submit the T&M document
#  Return to Award or close



#  Scenario: Award hierarchy child nodes created for every project year.
