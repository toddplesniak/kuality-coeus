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

#DEBUG this test is wrong and not needed
#but create a committee should be in a future test
#  @wip
#  Scenario: IACUC add a species to the protocol
#    Given the IACUC Administrator creates an IACUC Committee with an area of research
#    And   the IACUC Protocol Creator creates an IACUC Protocol
#    When  adds a Species group to the IACUC Protocol
#    Then  the IACUC Protocol status should be Pending/In Progress


