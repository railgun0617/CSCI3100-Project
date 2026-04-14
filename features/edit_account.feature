Feature: Edit Account Page
  
  As a student
  So that I can edit my account
  I want to able to change my email and password

  Background:
    Given I am logged in as a student
    And I am on the edit account page

  Scenario: Update Email successfully
    Given I fill in the Email as "abc@link.cuhk.edu.hk"
    And I fill in the Current password as "password123"
    When I click the "Update" button
    Then I should see "Your account has been updated successfully."

  Scenario: Update Password successfully
    Given I fill in the New password as "123456789"
    And I fill in the Confirm new password as "123456789"
    And I fill in the Current password as "password123"
    When I click the "Update" button
    Then I should see "Your account has been updated successfully."  

  Scenario: Cancel Account
    When I click the "Cancel my account" button
    Then I should see the message "Bye! Your account has been successfully cancelled. We hope to see you again soon."

  Scenario: Go back to previous page
    Given I am on the equipment and venue page
    When I click the "Edit Account" link
    Then I should be on the edit account page
    When I click the "Back" link
    Then I should be on the equipment and venue page