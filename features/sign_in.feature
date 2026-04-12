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
    When I fill in the Email as "1155123456@link.cuhk.edu.hk"
    And I fill in the Password as "password123"
    And I click the "Log in" button
    Then I should see the message "Signed in successfully."
    And I am on the main page
    
  Scenario: Incorrect or Not Exist Email
    Given I am on the sign in page
    And I fill in the Email as "1155@link.cuhk.edu.hk"
    And I fill in the Password as "password123"
    When I click the "Log in" button
    Then I should see the warning message "Invalid email or password."

  Scenario: Incorrect Password
    Given I am on the sign in page
    And I fill in the Email as "1155123456link.cuhk.edu.hk"
    And I fill in the Password as "asdfghjkl"
    When I click the "Log in" button
    Then I should see the warning message "Invalid email or password."
