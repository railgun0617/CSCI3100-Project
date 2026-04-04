Feature: Booking Page

  As a student
  So that I can see what equipments and venues I had booked
  I want to check my booking

  Scenario: See All of the Booking
    Given I book the equipment "Projector"
    And I book the venue "Library"
    When I am on the booking page
    Then I should see the booking for the equipment "Projector"
    And I should see the booking for the venue "Library"

