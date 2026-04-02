Feature: Equipment Page

  As a student
  So that I can book the equipments from the website
  I want to check the equipments

  Scenario: See All of the Equipments
    Given the equipment "Projector" exists
    And I am on the equipment page
    Then I should see the equipment "Projector"