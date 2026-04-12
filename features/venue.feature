Feature: Manage Resource Page (Venue Part)

  As a teacher
  So that I want to see and manage the venues
  I want to see, add, edit and delete venues

  Background:
    Given the venue "Library" exists
    And I am logged in as a staff
    And I am on the manage resources page

  Scenario: See All of the Venues
    Given the venue "Library" exists
    When I visit the venue page
    Then I should see the venue "Library"

  Scenario: Cancel Add Venue
    Given I am on the add venue page
    When I click the "Cancel" link
    Then I should be on the venue page
  
  @javascript
  Scenario: Successful Add Venue
    Given I am on the add venue page
    And I fill in the Name as "CC Library"
    And I fill in the Description as "A place for study"
    And I fill in the Capacity as "100"
    And I select the Opening Time as "10:00"
    And I select the Closing Time as "17:00"
    And I select position with latitude: 22.419538 and longitude: 114.205059 on the map
    And I click the "Create Venue" button
    Then I should see the message "Venue was successfully created."
    And I should be on the details page for venue "CC Library"

  Scenario: Fail Add Venue
    Given I am on the add venue page
    When I click the "Create Venue" button
    Then I should see the error message "Name can't be blank"
    And I should be on the add venue page

  Scenario: Cancel Edit Venue
    Given I am on the edit venue page for venue "Library"
    When I click the "Cancel" link
    Then I should be on the venue page

  Scenario: Successful Edit venue
    Given I am on the edit venue page for venue "Library"
    And I fill in the Description as "Another Library"
    And I select the Opening Time as "09:00"
    And I select the Closing Time as "15:00"
    And I click the "Update Venue" button
    Then I should see the message "Venue was successfully updated."
    And I should be on the details page for venue "Library"

  Scenario: Fail Edit Venue
    Given the venue "Library" exists
    And I am on the edit venue page for venue "Library"
    And I select the Opening Time as "12:00"
    And I select the Closing Time as "11:00"
    And I click the "Update Venue" button
    Then I should see the error message "venue close time must be after open time."
    And I should be on the edit venue page for venue "Library"

  Scenario: Successful Delete Venue
    When I click the "Delete" button of the venue "Library"
    Then I should see "Venue was successfully deleted."
    And I should be on the venue page

  Scenario: Students accidentally go to Manage Resources Page
    Given I am logged in as a student
    When I visit the manage resources page
    Then I should see the error message "Access denied."
