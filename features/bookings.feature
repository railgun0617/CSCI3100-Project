Feature: Booking Page

  As a student
  So that I can enjoy different equipments and venues
  I want to make a booking

  Background:
    Given I am logged in as a student
    And the equipment "Projector" exists with 2 quantity
    And the venue "Library" exists
    And the current time is "2025-10-06 13:00:00"

  @javascript
  Scenario: Successful Booking an Equipment
    Given I am on the equipment and venue page
    When I click "Book" of the equipment "Projector"
    Then I should see the title "Book Projector"
    When I select 1 quantity at date "Monday, Oct 06" and timeslot "02:00 PM"
    And I click "Book" at date "Monday, Oct 06" and timeslot "02:00 PM"
    Then I should find the notification "Booking submitted! Waiting for approval." on the top
    And I should be on the booking page of the equipment "Projector"
    And I should see the date "Monday, Oct 06" and timeslot "02:00 PM" cannot pick 2 quantity
  
  Scenario: Unavailable Booking Slots
    Given I have booked the equipment "Projector" with 2 quantity at date "Tuesday, Oct 07" and timeslot "02:00PM"
    And I have booked the equipment "Projector" with 2 quantity at date "Wednesday, Oct 08" and timeslot "10:00 AM"
    And I have booked the equipment "Projector" with 1 quantity at date "Thursday, Oct 09" and timeslot "01:00 PM"
    When I am on the equipment and venue page
    And I click "Book" of the equipment "Projector"
    Then I should see the title "Book Projector"
    Then I should see the date "Monday, Oct 06" and timeslot "11:00 AM" is unavailable
    And I should see the date "Monday, Oct 06" and timeslot "01:00 PM" is unavailable
    And I should see the date "Tuesday, Oct 07" and timeslot "02:00PM" is unavailable
    And I should see the date "Wednesday, Oct 08" and timeslot "10:00 AM" is unavailable
    And I should see the date "Thursday, Oct 09" and timeslot "01:00 PM" cannot pick 2 quantity
    And I should see the date "Saturday, Oct 11" and timeslot "02:00 PM" is unavailable

  @javascript
  Scenario: Successful Booking a Venue
    Given I am on the equipment and venue page
    When I click "Book" of the venue "Library"
    Then I should see the title "Book Library"
    When I click "Book" at date "Friday, Oct 10" and timeslot "12:00 PM"
    Then I should find the notification "Booking submitted! Waiting for approval." on the top
    And I should be on the booking page of the venue "Library"
    And I should see the date "Friday, Oct 10" and timeslot "12:00 PM" is unavailable

  Scenario: See All of the Booking
    Given I have booked the equipment "Projector" with 2 quantity at date "Monday, Oct 06" and timeslot "03:00 PM"
    And I have booked the venue "Library" at date "Tuesday, Oct 07" and timeslot "12:00 PM"
    When I am on the my bookings page
    Then I should see a booking for the equipment "Projector" with date "2025-10-06" and time "15:00 - 16:00" and status "Pending"
    And I should see a booking for the venue "Library" with date "2025-10-07" and time "12:00 - 13:00" and status "Pending"
    