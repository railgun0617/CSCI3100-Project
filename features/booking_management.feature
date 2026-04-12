Feature: Booking Management Page

  As a staff
  So that I can manage pending bookings
  I want to approve or reject bookings

  Background:
    Given I am logged in as a student
    And the equipment "Projector" exists with 2 quantity
    And the venue "Library" exists
    And the current time is "2025-10-04 08:00:00"
    And I have booked the equipment "Projector" with 2 quantity at date "Monday, Oct 06" and timeslot "11:00 AM"
    And I have booked the venue "Library" at date "Tuesday, Oct 07" and timeslot "02:00 PM"
    And I am logged in as a staff
    And I am on the staff dashboard page

  Scenario: Successful Approve Booking
    When I click "Approve" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the message "Booking approved."
    When I click "Approve" for the venue "Library" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-07 14:00" and end at "2025-10-07 15:00"
    Then I should see the message "Booking approved."
    When I am logged in as a student
    And I am on the my bookings page
    Then I should see a booking for the equipment "Projector" with date "2025-10-06" and time "11:00 - 12:00" and status "Approved"
    And I should see a booking for the venue "Library" with date "2025-10-07" and time "14:00 - 15:00" and status "Approved"

  Scenario: Successful Reject Booking
    When I click "Reject" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the message "Booking rejected."
    When I click "Reject" for the venue "Library" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-07 14:00" and end at "2025-10-07 15:00"
    Then I should see the message "Booking rejected."
    When I am logged in as a student
    And I am on the my bookings page
    Then I should see a booking for the equipment "Projector" with date "2025-10-06" and time "11:00 - 12:00" and status "Rejected"
    And I should see a booking for the venue "Library" with date "2025-10-07" and time "14:00 - 15:00" and status "Rejected"

  Scenario: Fail Approve and Reject Booking
    Given I am logged in as an admin
    Given I click "Approve" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    And I click "Reject" for the venue "Library" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-07 14:00" and end at "2025-10-07 15:00"
    When I click "Approve" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the error message "Failed to approve booking."
    When I click "Reject" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the error message "Failed to reject booking."
    When I click "Approve" for the venue "Library" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-07 14:00" and end at "2025-10-07 15:00"
    Then I should see the error message "Failed to approve booking."
    When I click "Reject" for the venue "Library" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-07 14:00" and end at "2025-10-07 15:00"
    Then I should see the error message "Failed to reject booking."

  Scenario: Successful Delete Booking
    When I click "Delete" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the message "Booking was successfully deleted."
    When I am on the my bookings page
    Then I should not see a booking for the equipment "Projector" with date "2025-10-06" and time "11:00 - 12:00"

  Scenario: Student Try to go to Booking Management Page
    Given I am logged in as a student
    When I visit the staff dashboard page
    Then I should see the error message "Access denied."
