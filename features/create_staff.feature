Feature: Create Staff Page

  As a staff
  So that I can add more staffs into the system
  I want to create a staff account

  Background: 
    Given I am logged in as a staff

  Scenario: Successful Staff Creation
    Given I am on the create staff page
    And I type the Email as "staff123@link.cuhk.edu.hk"
    And I type the Password as "password123"
    And I type the Password confirmation as "password123"
    When I click the "Create Staff Account" button
    Then I should see the message "Staff account created for staff123@link.cuhk.edu.hk."

  Scenario: Fail Staff Creation
    Given I am on the create staff page
    And I type the Email as "staff123@link.cuhk.edu.hk"
    And I type the Password as "abc"
    And I type the Password confirmation as "qwerty"
    When I click the "Create Staff Account" button
    Then I should see the error message "Password confirmation doesn't match Password"
    And I should see the error message "Password is too short (minimum is 6 characters)"
