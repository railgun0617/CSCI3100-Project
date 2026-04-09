include ActiveSupport::Testing::TimeHelpers

Given(/^the current time is "(.*?)"$/) do |time_string|
  travel_to Time.zone.parse(time_string)
end

After do
  travel_back
end

Given(/^I have booked the equipment "(.*?)" with (\d+) quantity at date "(.*?)" and timeslot "(.*?)"$/) do |name, quantity, date_str, timeslot_str|
  equipment = create(:equipment, name: "#{name}")
  slot_time = parse_slot_time(date_str, timeslot_str)
    create(:booking_equipment,
    user: @student || @staff,
    equipment: equipment,
    start_time: slot_time,
    end_time: slot_time + 1.hour,
    quantity: quantity.to_i,
    status: "pending"
  )
end

Given(/^I have booked the venue "(.*?)" at date "(.*?)" and timeslot "(.*?)"$/) do |name, date_str, timeslot_str|
  venue = create(:venue, name: "#{name}")
  slot_time = parse_slot_time(date_str, timeslot_str)
    create(:booking_venue,
    user: @student || @staff,
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
  slot_time = parse_slot_time(date_str, timeslot_str)

  btn_id = "btn_#{slot_time.to_i}"
  find("select.quantity-select[data-btn-id='#{btn_id}']", visible: true, match: :first).select(quantity)
end

When(/^I click "Book" at date "(.*?)" and timeslot "(.*?)"$/) do |date_str, timeslot_str|
  slot_time = parse_slot_time(date_str, timeslot_str)
  btn_id = "btn_#{slot_time.to_i}"
  if page.has_css?("select.quantity-select[data-btn-id='#{btn_id}']")
    select_el = find("select.quantity-select[data-btn-id='#{btn_id}']", visible: true, match: :first)
    row = select_el.first(:xpath, "ancestor::tr")
    within(row) do
      click_button("Book")
    end
  else
    find("##{btn_id}").click
  end
end

When(/^I click "(.*?)" for the equipment "(.*?)" booked by "(.*?)" start at "(.*?)" and end at "(.*?)"$/) do |action, equipment, email, start_time, end_time|
  within(:xpath, "//tr[td[contains(.,'#{equipment}') and contains(.,'Equipment')] 
                     and td[contains(.,'#{email}')] 
                     and td[contains(.,'#{start_time}')] 
                     and td[contains(.,'#{end_time}')]]") do
    click_button(action)
  end
end

Then (/^I should be on the booking page of the (.*?) "(.*?)"$/) do |item_type, item_name|
  case item_type
  when 'equipment'
    equipment = Equipment.find_by(name: item_name)
    expect(current_path).to eq(new_booking_path(resource_id: equipment.id, resource_type: 'equipment'))
  when 'venue'
    venue = Venue.find_by(name: item_name)
    expect(current_path).to eq(new_booking_path(resource_id: venue.id, resource_type: 'venue'))
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

Then(/^I should see a booking for the equipment "(.*?)" with date "(.*?)" and time "(.*?)" and status "(.*?)"$/) do |equipment, date, time_range, status|
  row = all("tbody tr").find do |r|
    r.has_text?("#{equipment} (Equipment)") &&
      r.has_text?(date) &&
      r.has_text?(time_range) &&
      r.has_text?(status)
  end
  expect(row).to be_present, "expected to find a row for #{equipment} #{date} #{time_range} with status #{status}"
end

Then(/^I should not see a booking for the equipment "(.*?)" with date "(.*?)" and time "(.*?)"$/) do |equipment, date, time_range|
  row = all("tbody tr").find do |r|
    r.has_text?("#{equipment} (Equipment)") &&
      r.has_text?(date) &&
      r.has_text?(time_range)
  end
  expect(row).to be_nil, "expected not to find a row for #{equipment} #{date} #{time_range}"
end

Then(/^I should see a booking for the venue "(.*?)" with date "(.*?)" and time "(.*?)" and status "(.*?)"$/) do |venue, date, time_range, status|
  row = all("tbody tr").find do |r|
    r.has_text?("#{venue} (Venue)") &&
      r.has_text?(date) &&
      r.has_text?(time_range) &&
      r.has_text?(status)
  end
  expect(row).to be_present, "expected to find a row for #{venue} #{date} #{time_range} with status #{status}"
end

Then(/^I should not see a booking for the venue "(.*?)" with date "(.*?)" and time "(.*?)"$/) do |venue, date, time_range|
  row = all("tbody tr").find do |r|
    r.has_text?("#{venue} (Venue)") &&
      r.has_text?(date) &&
      r.has_text?(time_range)
  end
  expect(row).to be_nil, "expected not to find a row for #{venue} #{date} #{time_range}"
end

Then(/^I should see equipment "(.*?)" booked by "(.*?)" start at "(.*?)" and end at "(.*?)" have status "(.*?)"$/) do |equipment, email, start_time_str, end_time_str, status|
  within(:xpath, "//tr[td[contains(.,'#{equipment}')] and td[contains(.,'#{email}')] and td[contains(.,'#{start_time_str}')] and td[contains(.,'#{end_time_str}')]]") do
    expect(page).to have_content(status)
  end
end

Then(/^I should not see equipment "(.*?)" booked by "(.*?)" start at "(.*?)" and end at "(.*?)" have status "(.*?)"$/) do |equipment, email, start_time_str, end_time_str, status|
  xpath = "//tr[td[contains(.,'#{equipment}')] and td[contains(.,'#{email}')] and td[contains(.,'#{start_time_str}')] and td[contains(.,'#{end_time_str}')] and td[contains(.,'#{status}')]]"
  expect(page).not_to have_xpath(xpath)
end

Then(/^I should see venue "(.*?)" booked by "(.*?)" start at "(.*?)" and end at "(.*?)" have status "(.*?)"$/) do |venue, email, start_time_str, end_time_str, status|
  within(:xpath, "//tr[td[contains(.,'#{venue}')] and td[contains(.,'#{email}')] and td[contains(.,'#{start_time_str}')] and td[contains(.,'#{end_time_str}')]]") do
    expect(page).to have_content(status)
  end
end

Then(/^I should not see venue "(.*?)" booked by "(.*?)" start at "(.*?)" and end at "(.*?)" have status "(.*?)"$/) do |venue, email, start_time_str, end_time_str, status|
  xpath = "//tr[td[contains(.,'#{venue}')] and td[contains(.,'#{email}')] and td[contains(.,'#{start_time_str}')] and td[contains(.,'#{end_time_str}')] and td[contains(.,'#{status}')]]"
  expect(page).not_to have_xpath(xpath)
end
