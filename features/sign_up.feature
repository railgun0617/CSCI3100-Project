Feature: Sign Up Page
  
  As a student
  So that I can book equipment and venues
  I want to sign up an account

  Background:
    Given I am on the sign up page

  Scenario: Successful Registerion
    Given I am on the equipment and venue page
    When I click the "Sign Up" link
    Then I should be on the sign up page
    And I fill in the Email as "1155123456@link.cuhk.edu.hk"
    And I fill in the Password as "qwerty123"
    And I fill in the Password confirmation as "qwerty123"
    When I click the "Sign Up" button
    Then I should see the message "Welcome! You have signed up successfully."

  Scenario: Blank Email and Password
    When I click the "Sign Up" button
    Then I should see the error message "Email can't be blank"
    And I should see the error message "Password can't be blank"

  Scenario: Duplicated Email
    Given I have signed up as a student
    And I fill in the Email as "1155123456@link.cuhk.edu.hk"
    And I fill in the Password as "asdfghjkl"
    And I fill in the Password confirmation as "asdfghjkl"
    When I click the "Sign Up" button
    Then I should see the error message "Email has already been taken"


  Scenario: Mismatched Password Confirmation
    And I fill in the Email as "1155123456@link.cuhk.edu.hk"
    And I fill in the Password as "qwerty123"
    And I fill in the Password confirmation as "qwertt123"
    When I click the "Sign Up" button
    Then I should see the error message "Password confirmation doesn't match Password"

  Scenario: Password Too Short
    And I fill in the Email as "1155123456@link.cuhk.edu.hk"
    And I fill in the Password as "156"
    And I fill in the Password confirmation as "156"
    When I click the "Sign Up" button
    Then I should see the error message "Password is too short (minimum is 6 characters)"
    