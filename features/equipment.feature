Feature: Manage Resources Page (Equipment Part)

  As a teacher
  So that I want to see and manage the equipments
  I want to see, add, edit and delete equipments

  Background:
    Given the equipment "Projector" exists with 2 quantity
    And I am logged in as a staff
    And I am on the manage resources page
    
  Scenario: See All of the Equipments
    Given the equipment "Microphone" exists with 3 quantity
    When I am on the equipment page
    Then I should see the equipment "Projector"
    Then I should see the equipment "Microphone"

  Scenario: Cancel Add Equipment
    Given I am on the add equipment page
    When I click the "Cancel" link
    Then I should be on the equipment page
  
  @javascript
  Scenario: Successful Add Equipment
    Given I am on the add equipment page
    And I fill in the Name as "Projector 2"
    And I fill in the Description as "HD Projector"
    And I fill in the Location as "ERB Room 101"
    And I fill in the Quantity as "5"
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
    And I fill in the Description as "Very Good Projector"
    And I fill in the Location as "MMW Room 102"
    And I fill in the Quantity as "4"
    And I click the "Update Equipment" button
    Then I should see the message "Equipment was successfully updated."
    And I should be on the details page for equipment "Projector"

  Scenario: Fail Edit Equipment
    Given I am on the edit equipment page for equipment "Projector"
    When I fill in the Name as ""
    And I click the "Update Equipment" button
    Then I should see the error message "Name can't be blank"
    And I should be on the edit equipment page for equipment "Projector"

  Scenario: Successful Delete Equipment
    When I click the "Delete" button of the equipment "Projector"
    Then I should see "Equipment was successfully deleted."
    And I should be on the equipment page
    And I should not see the equipment "Projector"  

