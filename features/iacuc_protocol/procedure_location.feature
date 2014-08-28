@IACUC
Feature: Add, edit, delete procedures locations on IACUC protocol

  As a researcher I want the ability to add edit and remove procedure locations from the IACUC Protocol

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @wip @KCTEST-918
  Scenario: Create a IACUC proposal
    When the IACUC Protocol Creator creates an IACUC Protocol with one species group
    And assigns a procedure to the personnel for location Performance Site
    Then the summary will display the location of the procedure