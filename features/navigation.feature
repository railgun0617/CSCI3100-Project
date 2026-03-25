# Line Coverage Report: coverage\index.html

Feature: Navigation from one page to another

  As a student
  So that I can enjoy some functions from the website
  I want to go to different pages

  Scenario: go to main page
    Given I am on the login page
    When I click 'CUHK Booking'
    Then I should be on the main page
