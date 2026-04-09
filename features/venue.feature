Feature: Venue Page

  As a student
  So that I can book the venues from the website
  I want to check the venues

  Scenario: See All of the Venues
    Given the venue "Library" exists
    When I am on the venue page
    Then I should see the venue "Library"
