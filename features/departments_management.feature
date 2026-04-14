Feature: Manage Department Page

  As an admin
  So that I can manage department
  I want to add, edit or delete departments

  Background:
    Given I am logged in as an admin
    And the department "NA College" exists
    And I am on the manage departments page

  Scenario: Successful Add Depearment
    When I click the "Add Department" link
    And I fill in the Name as "Department of Mathematics"
    And I fill in the Slug as "mathematics-department"
    And I click the "Create Department" button
    Then I should be on the manage departments page
    And I should see the message "Department 'Department of Mathematics' created successfully."
    And I should see the department "Department of Mathematics"

  Scenario: Fail Add Department
    When I click the "Add Department" link
    And I fill in the Name as ""
    And I click the "Create Department" button
    Then I should see the error message "Name can't be blank"

  Scenario: Cancel Add Equipment
    When I click the "Add Department" link
    And I click the "Cancel" link
    Then I should be on the manage departments page

  Scenario: Successful Edit Department
    When I click the "Edit" button of the department "NA College"
    And I fill in the Name as "Department of Computer Science and Engineering"
    And I click the "Update Department" button
    Then I should be on the manage departments page
    And I should see the message "Department updated successfully."
    And I should see "Department of Computer Science and Engineering"

  Scenario: Fail Edit Department
    Given the department "Shaw College" exists
    And I am on the manage departments page
    When I click the "Edit" button of the department "NA College"
    And I fill in the Name as "Shaw College"
    And I click the "Update Department" button
    Then I should see the error message "Name has already been taken"

  Scenario: Successful Delete Department
    When I click the "Delete" button of the department "NA College"
    Then I should be on the manage departments page
    And I should see the message "Department deleted."
    And I should not see "NA College"

  Scenario: Fail Delete Admain Department
    When I click the "Delete" button of the department "Admin"
    Then I should see the error message "The Admin department cannot be deleted."

  Scenario: Fail Delete Department
    Given the department "Department of Computer Science and Engineering" exists with a user
    And I am on the manage departments page
    When I click the "Delete" button of the department "Department of Computer Science and Engineering"
    Then I should see the error message "Cannot delete department with associated resources."

  Scenario: Department Names Sorted in Alphabetic Order
    Given the department "Shaw College" exists
    Given the department "Department of Social Science" exists
    Given the department "Department of Mathematics" exists
    Given the department "Department of Computer Science and Engineering" exists
    When I visit the manage departments page
    Then I should find "Department of Computer Science and Engineering" before "Department of Mathematics"
    And I should find "Department of Mathematics" before "Department of Social Science"
    And I should find "Department of Social Science" before "NA College"
    And I should find "NA College" before "Shaw College"
