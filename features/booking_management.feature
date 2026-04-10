Feature: Booking Management Page

  As a staff
  So that I can manage pending bookings
  I want to approve or reject bookings

  Background:
    Given I am logged in as a student
    And the equipment "Projector" exists with 2 quantity
    And the current time is "2025-10-04 08:00:00"
    And I have booked the equipment "Projector" with 2 quantity at date "Monday, Oct 06" and timeslot "11:00 AM"
    And I am logged in as a staff
    And I am on the staff dashboard page

  Scenario: Approve Booking
    When I click "Approve" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the message "Booking approved."
    And I should see equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00" have status "Approved"
    When I am logged in as a student
    And I am on the my bookings page
    Then I should see a booking for the equipment "Projector" with date "2025-10-06" and time "11:00 - 12:00" and status "Approved"

  Scenario: Reject Booking
    When I click "Reject" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the message "Booking rejected."
    And I should see equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00" have status "Rejected"
    When I am logged in as a student
    And I am on the my bookings page
    Then I should see a booking for the equipment "Projector" with date "2025-10-06" and time "11:00 - 12:00" and status "Rejected"

  Scenario: Delete Booking
    When I click "Delete" for the equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00"
    Then I should see the message "Booking was successfully deleted."
    And I should not see equipment "Projector" booked by "1155123456@link.cuhk.edu.hk" start at "2025-10-06 11:00" and end at "2025-10-06 12:00" have status "Rejected"
    When I am on the my bookings page
    Then I should not see a booking for the equipment "Projector" with date "2025-10-06" and time "11:00 - 12:00"
