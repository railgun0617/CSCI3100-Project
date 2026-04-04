Feature: Equipment and Venue Page

  As a staff
  So that I can add more staffs into the system
  I want to create a staff account

  Scenario: Successful Staff Creation
    Given I am on the create staff page
    And I type the Email as "1155123456@link.cuhk.edu.hk"
    And I type the Password as "password123"
    And I type the Password confirmation as "password123"
    When I click the "Create Staff Account" button
    Then I should see the message "Staff account created for 1155123456@link.cuhk.edu.hk."


