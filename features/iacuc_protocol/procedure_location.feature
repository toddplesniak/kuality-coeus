@IACUC
Feature: Add, edit, delete procedures locations on IACUC protocol

  As a researcher I want the ability to add edit and remove procedure locations from the IACUC Protocol

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip @KCTEST-918
  Scenario: Create a IACUC proposal
    Given the IACUC Protocol Creator creates an IACUC Protocol with one Species
    And   adds a Procedure to the IACUC Protocol
    When  assigns a location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    Then  the summary will display the location of the procedure

  @wip @KCTEST-915
  Scenario: The system shall allow implementing institutions to maintain (add) a location type with a name
    Given the Application Administrator creates a new Location type
    Then there are no errors on the page
    And  adds a location name to the location type
    When the IACUC Protocol Creator assigns the created location to a Procedure on the IACUC Protocol
    Then  the summary will display the location of the procedure