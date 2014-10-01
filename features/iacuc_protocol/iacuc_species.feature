@IACUC
Feature: Add, edit, delete specieson IACUC protocol

  As a researcher I want the ability to add edit and remove species on the IACUC Protocol

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator

  @wip @KCTEST-904
  Scenario: Verify species count on the IACUC Protocol displays an error when letters
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When IACUC Protocol Creator attempts to add a Species with non-integers as the species count
    Then an error should appear warning that the field contents are not valid

  @wip
  Scenario: Adding a Species to the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When the IACUC Protocol Creator adds a Species with all options
    When saves the IACUC Protocol after modifying the required fields for the Species
    Then the group name, species, pain category, count type, species count should match the modified values

  @wip
  Scenario: Delete an existing Species on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    And  adds a Species to the IACUC Protocol
    And  adds a second Species to the IACUC Protocol
    When the IACUC Protocol Creator deletes the first Species
    Then the second Species added should be the only Species on the IACUC Protocol


