Feature: Booking Page

  As a student
  So that I can enjoy different equipments and venues
  I want to make a booking

  Background:
    Given I am logged in as a student

  Scenario: See All of the Booking
    Given I book the equipment "Projector"
    And I book the venue "Library"
    When I am on the booking page
    Then I should see the booking for the equipment "Projector"
    And I should see the booking for the venue "Library"

  Scenario: Book an item
    Given I am on the equipment and venue page
    And the current time is "2020-01-04 08:00:00" # 2020-01-04 is Saturday
    When I click "Book"
    Then I should see "Book Library"
    And I should see "Select an available time slot for the next 7 days."
    And I should find the time slot "Saturday, Jan 04 09:00 AM" is closed
    And I should find the time slot "Sunday, Jan 05 03:00 PM" is closed
    And I should find the time slot "Monday, Jan 06 11:00 AM" is available
    And I should find the time slot "Friday, Jan 06 12:00 PM" is available
    When I click "Book" at the time slot "Monday, Jan 06 11:00 AM"
    Then I should see the message "Booking request submitted for Jan 06 11:00 AM."
    And I should see "Library (Venue)	2026-04-06	13:00 - 14:00	Pending"
