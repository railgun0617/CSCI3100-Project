include ActiveSupport::Testing::TimeHelpers

Given(/^the current time is "(.*)"$/) do |time_string|
  travel_to Time.zone.parse(time_string)
end

After do
  travel_back # reset time after each scenario
end

Given (/^I book the (.*?) "(.*?)"$/) do |item_type, item_name|
  case item_type
  when 'equipment'
    # @booking = Booking.create(resource: @equipment, user: @user, start_time: Time.now, end_time: Time.now + 1.hour)
  when 'venue'
    # @booking = Booking.create(resource: @venue, user: @user, start_time: Time.now, end_time: Time.now + 1.hour)
  else
    raise 'Unknown Item Type'
  end
end

Then (/^I should see the booking for the (.*?) "(.*?)"$/) do |item_type, item_name|
  # expect(page).to have_content("Booking for #{item_name}")
end