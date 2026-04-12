Feature: Navigation from one page to another

  As a student
  So that I can enjoy some functions from the website
  I want to go to different pages

  Scenario: go to main page
    Given I am on the sign in page
    When I click the "CUHK Booking" link
    Then I should be on the main page
