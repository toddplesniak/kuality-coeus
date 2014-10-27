@IACUC
Feature: Add, edit, delete procedures locations on IACUC protocol

  As a researcher I want the ability to create, add, edit and delete procedure locations for an IACUC Protocol

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip @KCTEST-915 @KCTEST-918
  Scenario: Implementing institutions can create a location type with a name to use for IACUC Protocols
    Given the Application Administrator creates a new Location type maintenance document
    Then  there are no errors on the page
    And   adds a location name to the location type maintenance document
    When  the IACUC Protocol Creator assigns the created location to a Procedure on the IACUC Protocol
    Then  the summary will display the location of the procedure

  @wip @KCTEST-915
  Scenario: Implementing institutions can edit a existing location name to use for IACUC Protocols
    Given the Application Administrator creates a new Location type maintenance document
    Then  there are no errors on the page
    And   adds a location name to the location type maintenance document
    When  edits the location name on the maintenance document
    And  the IACUC Protocol Creator creates an IACUC Protcol with the edited location name for a Procedure
    Then  the summary will display the location of the procedure

  @wip @KCTEST-918
  Scenario: Edit the location of a procedure on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol with one Species
    And   adds a Procedure to the IACUC Protocol
    When  assigns a location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    And   edits the location type, name, room, description on the IACUC Protocol
    Then  the edited location information should be dispalyed on the IACUC Protocol

  @wip @KCTEST-918
  Scenario: Delete a location from a procedure on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol with one Species
    And   adds a Procedure to the IACUC Protocol
    When  assigns a location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    And   assigns a second location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    And   deletes the first location from the Procedure
    Then  the first location is not listed on the IACUC Protocol
    And   the second location is listed on the IACUC Protocol


