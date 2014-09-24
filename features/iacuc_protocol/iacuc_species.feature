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


