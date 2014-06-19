#Feature: IRB Protocol Actions
#
#  TBD
#
#  Background:
#    * a User exists with the role: 'Protocol Creator'
#    * the Protocol Creator user creates an IRB Protocol
#
#  Scenario Outline: Submission Review Type Checklist
#    When the Protocol is given an '<Type>' Submission Review Type
#    Then the <Checklist> Checklist can be filled out
#
#  Examples:
#    | Type      | Checklist        |
#    | Expedited | Expedited Review |
#    | Exempt    | Exempt Studies   |