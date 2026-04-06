Feature: Equipment Page

  As a teacher
  So that I want to manage the equipments
  I want to add, edit and delete equipments

  Background:
    Given I am logged in as a staff

  Scenario: See All of the Equipments
    Given the equipment "Projector" exists
    And the equipment "Microphone" exists
    When I am on the equipment page
    Then I should see the equipment "Projector"
    Then I should see the equipment "Microphone"

  Scenario: Cancel Add Equipment
    Given I am on the add equipment page
    When I click the "Cancel" link
    Then I should be on the equipment page
  
  @javascript
  Scenario: Successful Add Equipment
    # Given I am on the main page
    # When I click the "Manage Resources" link
    # Then I am on the manage resources page
    # When I click the "Add Equipment" link
    # Then I should be on the add equipment page
    Given I am on the add equipment page
    And I type the Name as "Projector"
    And I type the Description as "HD Projector"
    And I type the Location as "ERB Room 101"
    And I type the Quantity as "5"
    And I select position with latitude: 22.418199 and longitude: 114.207988 on the map
    And I click the "Create Equipment" button
    Then I should see the message "Equipment was successfully created."
    And I should be on the details page for equipment "Projector"

  Scenario: Fail Add Equipment
    Given I am on the add equipment page
    When I click the "Create Equipment" button
    Then I should see the error message "Name can't be blank"
    And I am on the add equipment page

  Scenario: Cancel Edit Equipment
    Given the equipment "Projector" exists
    Given I am on the edit equipment page for equipment "Projector"
    When I click the "Cancel" link
    Then I should be on the equipment page

  Scenario: Successful Edit Equipment
    Given the equipment "Projector" exists
    And I am on the edit equipment page for equipment "Projector"
    And I type the Description as "Very Good Projector"
    And I type the Location as "MMW Room 102"
    And I type the Quantity as "4"
    And I click the "Update Equipment" button
    Then I should see the message "Equipment was successfully updated."
    And I should be on the details page for equipment "Projector"

  Scenario: Fail Edit Equipment
    Given the equipment "Projector" exists
    And I am on the edit equipment page for equipment "Projector"
    When I type the Name as ""
    And I click the "Update Equipment" button
    Then I should see the error message "Name can't be blank"
    And I should be on the edit equipment page for equipment "Projector"

  Scenario: Delete Equipment
    Given I am on the manage resources page
    And the equipment "Projector" exists
    When I click the "Delete" button of the equipment "Projector"
    Then I should see "Equipment was deleted."
    And I should be on the equipment page