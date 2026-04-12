include ActiveSupport::Testing::TimeHelpers

Given(/^the current time is "(.*?)"$/) do |time_string|
  travel_to Time.zone.parse(time_string)
end

After do
  travel_back
end

Given(/^I have booked the equipment "(.*?)" with (\d+) quantity at date "(.*?)" and timeslot "(.*?)"$/) do |name, quantity, date_str, timeslot_str|
  equipment = Equipment.find_by(name: "#{name}")
  slot_time = parse_slot_time(date_str, timeslot_str)
  user = @student || @staff || create(:user, :student)
    create(:booking_equipment,
    user: user,
    equipment: equipment,
    start_time: slot_time,
    end_time: slot_time + 1.hour,
    quantity: quantity.to_i,
    status: "pending"
  )
end

Given(/^I have booked the venue "(.*?)" at date "(.*?)" and timeslot "(.*?)"$/) do |name, date_str, timeslot_str|
  venue = Venue.find_by(name: "#{name}")
  slot_time = parse_slot_time(date_str, timeslot_str)
  user = @student || @staff || create(:user, :student)
    create(:booking_venue,
    user: user,
    venue: venue,
    start_time: slot_time,
    end_time: slot_time + 1.hour,
    status: "pending"
  )
end

When (/^I click "Book" of the (.*?) "(.*?)"$/) do |item_type, item_name|
  case item_type
  when 'equipment'
    equipment = Equipment.find_by(name: item_name)
    within("#equipment_#{equipment.id}") do
      click_link "Book"
    end
  when 'venue'
    venue = Venue.find_by(name: item_name)
    within("#venue_#{venue.id}") do
      click_link "Book"
    end
  else
    raise 'Unknown Item Type'
  end
end

When(/^I select (\d+) quantity at date "(.*?)" and timeslot "(.*?)"$/) do |quantity, date_str, timeslot_str|
  row = all("tr").find { |tr| tr.has_text?(date_str) && tr.has_text?(timeslot_str) }
  within(row) do
    find("select.quantity-select").select(quantity)
  end
end


When(/^I click "Book" at date "(.*?)" and timeslot "(.*?)"$/) do |date_str, timeslot_str|
  row = all("tr").find { |tr| tr.has_text?(date_str) && tr.has_text?(timeslot_str) }
  within(row) { click_button("Book") }
end


When(/^I click "(.*?)" for the (equipment|venue) "(.*?)" booked by "(.*?)" start at "(.*?)" and end at "(.*?)"$/) do |button_text, item_type, item_name, user_email, start_time, end_time|
  row = all("tbody tr").find do |tr|
    tr.has_text?(item_name) &&
    tr.has_text?(user_email)
  end

  expect(row).to be_present, "Could not find booking row for #{item_type} #{item_name} #{user_email} #{start_time} - #{end_time}"

  within(row) do
    click_link_or_button(button_text)
  end
end

When(/^I try to approve a booking$/) do
  booking = Booking.create!(
    user: @student,
    venue: Venue.create!(name: "Library", description: "Quiet place", tenant: Tenant.create!(name: "NA College")),
    start_time: Time.zone.parse("2025-10-06 11:00"),
    end_time: Time.zone.parse("2025-10-06 12:00")
  )
  visit approve_booking_path(booking)
end

Then(/^I should be on the booking page of the (.*?) "(.*?)"$/) do |item_type, item_name|
  case item_type
  when 'equipment'
    equipment = Equipment.find_by!(name: item_name)
    expect(page).to have_current_path(
      new_booking_path(resource_id: equipment.id, resource_type: 'equipment'),
      ignore_query: false
    )
  when 'venue'
    venue = Venue.find_by!(name: item_name)
    expect(page).to have_current_path(
      new_booking_path(resource_id: venue.id, resource_type: 'venue'),
      ignore_query: false
    )
  else
    raise 'Unknown Item Type'
  end
end

Then(/^I should see the date "(.*?)" and timeslot "(.*?)" is unavailable$/) do |date_str, timeslot_str|
  slot_time = parse_slot_time(date_str, timeslot_str)
  btn_id = "btn_#{slot_time.to_i}"
  row = find(:xpath, "//tr[td[contains(.,'#{date_str}')]][td[contains(.,'#{timeslot_str}')]]")
  within(row) do
    expect(page).to have_content("Not available")
    expect(page).not_to have_selector("select.quantity-select", visible: :all)
    expect(page).not_to have_button("Book")
  end
end

Then(/^I should see the date "(.*?)" and timeslot "(.*?)" cannot pick (\d+) quantity$/) do |date_str, timeslot_str, quantity|
  slot_time = parse_slot_time(date_str, timeslot_str)
  btn_id = "btn_#{slot_time.to_i}"
  select_el = find("select.quantity-select[data-btn-id='#{btn_id}']", visible: :all, match: :first)
  row = select_el.first(:xpath, "ancestor::tr")
  within(row) do
    option = select_el.first("option[value='#{quantity}']", visible: :all) rescue nil
    if option.nil?
      expect(option).to be_nil
    else
      disabled_attr = option[:disabled] || option['aria-disabled']
      expect(disabled_attr).to be_truthy
    end
  end
end

Then (/^I should find the notification "(.*?)" on the top$/) do |notification|
  expect(page).to have_css('.custom-toast', text: notification)
end

Then(/^I should see a booking for the equipment "(.*?)" with date "(.*?)" and time "(.*?)" and status "(.*?)"$/) do |equipment, date, time_range, status|
  row = all("tbody tr").find do |r|
    r.has_text?("#{equipment} (equipment)") &&
      r.has_text?(date) &&
      r.has_text?(time_range) &&
      r.has_text?(status)
  end
  expect(row).to be_present, "expected to find a row for #{equipment} #{date} #{time_range} with status #{status}"
end

Then(/^I should not see a booking for the equipment "(.*?)" with date "(.*?)" and time "(.*?)"$/) do |equipment, date, time_range|
  row = all("tbody tr").find do |r|
    r.has_text?("#{equipment} (equipment)") &&
      r.has_text?(date) &&
      r.has_text?(time_range)
  end
  expect(row).to be_nil, "expected not to find a row for #{equipment} #{date} #{time_range}"
end

Then(/^I should see a booking for the venue "(.*?)" with date "(.*?)" and time "(.*?)" and status "(.*?)"$/) do |venue, date, time_range, status|
  row = all("tbody tr").find do |r|
    r.has_text?("#{venue} (venue)") &&
      r.has_text?(date) &&
      r.has_text?(time_range) &&
      r.has_text?(status)
  end
  expect(row).to be_present, "expected to find a row for #{venue} #{date} #{time_range} with status #{status}"
end

Then(/^I should not see a booking for the venue "(.*?)" with date "(.*?)" and time "(.*?)"$/) do |venue, date, time_range|
  row = all("tbody tr").find do |r|
    r.has_text?("#{venue} (venue)") &&
      r.has_text?(date) &&
      r.has_text?(time_range)
  end
  expect(row).to be_nil, "expected not to find a row for #{venue} #{date} #{time_range}"
end
