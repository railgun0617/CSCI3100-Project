Feature: Equipment and Venue Page

  As a student
  So that I can book the equipments and venues from the website
  I want to check the equipments and venues

  Background:
    Given the equipment "Projector" exists with desciption "HDMI projector" and location "ERB Room 101" and department "Department of Computer Science and Enginnering"
    And the venue "Library" exists with description "A quiet place to study" and department "NA College"
    And I am on the equipment and venue page

  Scenario: See All of the Equipments and Venues
    Then I should see the equipment "Projector"
    And I should see the venue "Library"

  Scenario: Search by Name
    When I type "Library" in search bar
    Then I should see the venue "Library"

  Scenario: Search by Description
    When I type "place to study" in search bar
    Then I should see the venue "Library"

  Scenario: Search by Location
    When I type "ERB" in search bar
    Then I should see the equipment "Projector"

  Scenario: Search by Department
    When I type "Computer Sci" in search bar
    Then I should see the equipment "Projector"

  Scenario: No Search Results
    When I type "Math" in search bar
    Then I should not see the equipment "Projector"
    And I should not see the venue "Library"