Feature: Equipment and Venue Page

  As a student
  So that I can book the equipments and venues from the website
  I want to check the equipments and venues

  Scenario: See All of the Equipments and Venues
    Given the equipment "Projector" exists
    And the venue "Library" exists
    And I am on the equipment and venue page
    Then I should see the equipment "Projector"
    And I should see the venue "Library"