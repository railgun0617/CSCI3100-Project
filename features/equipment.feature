Feature: Equipment Page

  As a teacher
  So that I want to manage the equipments
  I want to add, edit and delete equipments

  Background:
    Given I am logged in as a staff
    
  Scenario: See All of the Equipments
    Given the equipment "Projector" exists with 2 quantity
    And the equipment "Microphone" exists with 3 quantity
    When I am on the equipment page
    Then I should see the equipment "Projector"
    Then I should see the equipment "Microphone"

