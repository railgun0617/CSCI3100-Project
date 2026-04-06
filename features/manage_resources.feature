Feature: Manage Resources Page

  As a staff
  So that I can manage (add, edit and delete) the equipments and venues without letting students access
  I want to see all the equipments and venues without letting students access

  Scenario: See All of the Equipments and Venues
    Given I am a staff
    And the equipment "Projector" exists
    And the venue "Library" exists
    When I am on the manage resources page
    Then I should see the equipment "Projector"
    And I should see the venue "Library"

  Scenario: Students accidentally go to Manage Resources Page
    Given I am a student
    When I am on the manage resources page
    Then I should see the error message "Access denied."
