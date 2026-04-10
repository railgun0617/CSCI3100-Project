# Line Coverage Report: coverage\index.html
# open coverage/index.html        # macOS
# xdg-open coverage/index.html    # Linux
# start coverage/index.html       # Windows

Feature: Navigation from one page to another

  As a student
  So that I can enjoy some functions from the website
  I want to go to different pages

  Scenario: go to main page
    Given I am on the sign in page
    When I click the "CUHK Booking" link
    Then I should be on the main page
