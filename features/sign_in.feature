Feature: Sign In Page
  
  As a student
  So that I can book equipment and venues
  I want to sign in to book equipment and venues

  Background:
    Given I have signed up as a student
    And I am on the sign in page

  Scenario: Successful Login
    Given I am on the equipment and venue page
    When I click the "Sign In" link
    Then I should be on the sign in page
    When I type the Email as "1155123456@link.cuhk.edu.hk"
    And I type the Password as "password123"
    And I click the "Log in" button
    Then I should see the message "Signed in successfully."
    And I am on the main page
    
  Scenario: Incorrect or Not Exist Email
    Given I am on the sign in page
    And I type the Email as "1155@link.cuhk.edu.hk"
    And I type the Password as "password123"
    When I click the "Log in" button
    Then I should see the warning message "Invalid email or password."

  Scenario: Incorrect Password
    Given I am on the sign in page
    And I type the Email as "1155123456link.cuhk.edu.hk"
    And I type the Password as "asdfghjkl"
    When I click the "Log in" button
    Then I should see the warning message "Invalid email or password."

  Scenario: Testing 1
    Given I am logged in as a staff
    Given the equipment "Projector" exists with 2 quantity
    Given the venue "Library" exists
    When I am on the manage resources page
    Then I should be on the manage resources page
    And I should see "Manage Resources"
    And I should see the equipment "Projector"
    And I should see the venue "Library"
    And I should see "Add Venue"
    And I should see "Edit"
    And I should see "Delete"

  Scenario: Testing 2
    Given I am logged in as a staff
    When I am on the staff dashboard page
    Then I should be on the staff dashboard page
    