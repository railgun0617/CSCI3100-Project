Feature: Equipment and Venue Page

  As a student
  So that I can book the equipments and venues from the website
  I want to check the equipments and venues

  Scenario: See All of the Equipments and Venues
    Given I am logged in as a staff
    And the equipment "Projector" exists with 2 quantity
    And the venue "Library" exists
    When I am on the equipment and venue page
    Then I should see the equipment "Projector"
    And I should see the venue "Library"