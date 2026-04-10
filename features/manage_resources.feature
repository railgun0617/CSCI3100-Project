Feature: Manage Resources Page

  As a staff
  So that I can manage the equipments and venues
  I want to add, edit and delete the equipments and venues

  Background:
    Given the equipment "Projector" exists with 2 quantity
    And the venue "Library" exists
    And I am logged in as a staff
    And I am on the manage resources page

  Scenario: See All of the Equipments and Venues
    Then I should see the equipment "Projector"
    And I should see the venue "Library"

  Scenario: Cancel Add Equipment
    Given I am on the add equipment page
    When I click the "Cancel" link
    Then I should be on the equipment page
  
  @javascript
  Scenario: Successful Add Equipment
    Given I am on the add equipment page
    And I type the Name as "Projector 2"
    And I type the Description as "HD Projector"
    And I type the Location as "ERB Room 101"
    And I type the Quantity as "5"
    And I select position with latitude: 22.418199 and longitude: 114.207988 on the map
    And I click the "Create Equipment" button
    Then I should see the message "Equipment was successfully created."
    And I should be on the details page for equipment "Projector 2"

  Scenario: Fail Add Equipment
    Given I am on the add equipment page
    When I click the "Create Equipment" button
    Then I should see the error message "Name can't be blank"
    And I am on the add equipment page

  Scenario: Cancel Edit Equipment
    Given I am on the edit equipment page for equipment "Projector"
    When I click the "Cancel" link
    Then I should be on the equipment page

  Scenario: Successful Edit Equipment
    Given I am on the edit equipment page for equipment "Projector"
    And I type the Description as "Very Good Projector"
    And I type the Location as "MMW Room 102"
    And I type the Quantity as "4"
    And I click the "Update Equipment" button
    Then I should see the message "Equipment was successfully updated."
    And I should be on the details page for equipment "Projector"

  Scenario: Fail Edit Equipment
    Given I am on the edit equipment page for equipment "Projector"
    When I type the Name as ""
    And I click the "Update Equipment" button
    Then I should see the error message "Name can't be blank"
    And I should be on the edit equipment page for equipment "Projector"

  @javascript
  Scenario: Delete Equipment
    When I click the "Delete" button of the equipment "Projector"
    Then I should see "Equipment was successfully deleted."
    And I should be on the equipment page
    And I should not see the equipment "Projector"



  Scenario: Cancel Add Venue
    Given I am on the add venue page
    When I click the "Cancel" link
    Then I should be on the venue page
  
  @javascript
  Scenario: Successful Add Venue
    Given I am on the add venue page
    And I type the Name as "CC Library"
    And I type the Description as "A place for study"
    And I type the Capacity as "100"
    And I select the Opening Time as "10:00"
    And I select the Closing Time as "17:00"
    And I select position with latitude: 22.419538 and longitude: 114.205059 on the map
    And I click the "Create Venue" button
    Then I should see the message "Venue was successfully created."
    And I should be on the details page for venue "Library"

  Scenario: Fail Add Venue
    Given I am on the add venue page
    When I click the "Create Venue" button
    Then I should see the error message "Name can't be blank"
    And I am on the add venue page

  Scenario: Cancel Edit Venue
    Given I am on the edit venue page for venue "Library"
    When I click the "Cancel" link
    Then I should be on the venue page

  Scenario: Successful Edit venue
    Given I am on the edit venue page for venue "Library"
    And I type the Description as "Another Library"
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

  Scenario: Delete Venue
    When I click the "Delete" button of the venue "Library"
    Then I should see "Venue was successfully deleted."
    And I should be on the venue page

  Scenario: Students accidentally go to Manage Resources Page
    Given I am logged in as a student
    When I am on the manage resources page
    Then I should see the error message "Access denied."
