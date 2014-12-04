@Proposal
Feature: Project Personnel in Proposal Budget Versions

  To be written...

  Background:
    Given a User exists with the role: 'Proposal Creator'
    * the Proposal Creator creates a Proposal
    * creates a Budget Version for the Proposal

  Scenario: Syncing Personnel with Proposal
    Given the Proposal Creator adds a principal investigator to the Proposal
    And   adds a co-investigator to the Proposal
    And   adds a key person to the Proposal
    When  a Budget Version is created for the Proposal
    Then  the Budget personnel should match the Proposal personnel

  Scenario: Personnel info imported from Person record
    Given a User exists with a 'SUMMER EMPLOYEE' appointment type
    When  the Proposal Creator adds the 'SUMMER EMPLOYEE' User to the Budget personnel
    Then  the Budget personnel list shows the SUMMER EMPLOYEE's job code, salary, and appointment type info

  Scenario: Updating a key person's role
    Given the Proposal Creator adds a principal investigator to the Proposal
    And   adds a co-investigator to the Proposal
    And   syncs the Budget personnel with the Proposal personnel
    When  the Proposal Creator changes the Proposal's co-investigator to a key person
    Then  the Budget Version personnel list shows the correct roles

  Scenario: Adding Project Person with Salary and no Inflation Rate
    Given the Proposal Creator adds an employee to the Budget personnel
    When  a Project Person is assigned to Budget period 1, with no salary inflation
    Then  the Project Person's requested salary for the Budget period is as expected

=begin
  M5.4.2.c	Period Type Control	The system shall require a period type be entered before saving an assignment of personnel to period
  M5.4.3.b	Start Date Default	The system shall automatically populate the start date with the start date of that period
  M5.4.3.d	Start Date Modify	The system shall allow the user to change the default date
  M5.4.3.e	Start Date Control	The system shall require start date to be entered before saving an assignment of personnel to period
  M5.4.3.g	Start Date Constraint Error Message	The system shall provide the user with an error message when the start date does not conform to the required format. Ex: _____ is not a valid date.
  M5.4.4.b	End Date Default	The system shall automatically populate the end date with the end date of that period
  M5.4.4.c	End Date Modify	The system shall allow the user to change the default date
  M5.4.4.d	End Date Control	The system shall require end date to be entered before saving an assignment of personnel to period
  M5.4.4.e	End Date Constraint	The system shall require user entry in the format MM/DD/YYY
  M5.4.4.f	End Date Constraint Error Message	The system shall provide the user with an error message when the start date does not conform to the required format. Ex: _____ is not a valid date.
  M5.4.4.g	End Date Constraint Exception	The system shall automatically convert dates entered as either M/DD/YYYY or MM/D/YYYY to the MM/DD/YY format
  M5.4.4.h	End Date Calendar	The system shall provide a mechanism for the user to search for a end date

   M5.4.6.a	Percent Charge	The system shall allow user to specify the number for percentage of charge (expense) to applied for person within a period
  M5.4.6.b	Percent Charge Control	The system shall require charge be entered before saving an assignment of personnel to period
  M5.4.6.c	Percent Charge Constraint	The system shall require user entry in the format ###.##
  M5.4.6.d	Percent Charge Constraint Error Message	The system shall provide the user with an error message when the start date does not conform to the required format. Ex: Percentage Charge is not a valid percentage
  M5.4.6.e	Percent Charge Constraint Error Exception	The system shall automatically convert effort entered as ## or ### to the ###.## or ###.## format
  M5.4.7.a	Requested Salary	The system shall calculate a requested salary using the base salary, start and end dates and % charge to determine how much the person shall request in salary per period
  M5.4.7.b	Requested Salary Control	The system shall display the requested salary as a non-editable field
  M5.4.8.a	Calculated Fringe	The system shall display the requested salary multiplied by all the rates in the fringe benefits category to show amount of calculated fringe
  M5.4.8.b	Calculated Fringe Control	The system shall display the requested salary as a non-editable field
  M5.4.9.a	Cost Sharing Amount	The system shall show user the amount of cost sharing applicable per person
  M5.4.9.b	Cost Sharing Amount Trigger	The system shall calculate cost share for personnel whenever the percent amount of charge is less than the amount of effort
  M5.4.9.c	Cost Sharing Amount Control	The system shall not allow user to enter a salary greater than 12 digits
  M5.4.9.d	Cost Sharing Amount Control Error Message	The system shall provide user with a message to let the user know that cost sharing exceeds limit. Ex:The Rate Cost Sharing (Rate Cost Sharing) must be a fixed point number, with no more than 12 total digits and 2 digits to the right of the decimal point.
  M5.4.9.e	Cost Sharing Percentage	The system shall calculate the percentage of cost share, as determined by the percentage remaining for the percent charge to equal the percent effort
  M5.4.9.f	Cost Sharing Percentage Control	The system shall display percentage of cost sharing as a display only field
  M5.4.10.a	Unrecovered F&A	The system shall display the amount of F&A expected for the personnel but not gained because of user modification in F&A rate
  M5.4.10.b	Unrecovered F&A Control	The system shall always display, as non-editable, the unrecovered F&A, even if request is $0.00
  M5.4.11.a	Person Months	The system shall calculate person months by using the number of days in the start to end date divided by the percent effort.
  M5.4.11.b	Person Months Control	The system shall display the person months as a non-editable field
  M5.4.12.a	Description	The system shall allow the user to enter a brief description of the personnel assignment
  M5.4.12.b	Description Constraint	The system shall allow user to enter only 200 alphanumeric characters in the description field
  M5.4.12.c	Description Control	The system shall display the requested salary as a non-editable field
  M5.4.13	Personnel Calculate	The system shall allow the user to update the current calculations without saving the changes to the database
=end