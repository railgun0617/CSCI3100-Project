Given (/^the venue "(.*?)" exists$/) do |item|
  tenant = Tenant.find_or_create_by(name: "Department of Computer Science and Engineering")
  @venues ||= {}
  @venues[item] = Venue.create(
    name: item, tenant: tenant, description: "Description for #{item}",
    capacity: 50, open_time: Time.zone.parse("09:00"), close_time: Time.zone.parse("17:00"),
    latitude: 22.418199, longitude: 114.207988
  )
end

Given(/^the venue "(.*?)" exists with description "(.*?)" and department "(.*?)"$/) do |item, description, department|
  tenant = Tenant.find_or_create_by!(name: department)
  @venues ||= {}
  @venues[item] = Venue.create!(
    name: item,
    description: description,
    tenant: tenant,
    capacity: 50,
    open_time: Time.zone.parse("09:00"),
    close_time: Time.zone.parse("17:00"),
    latitude: 22.418199,
    longitude: 114.207988
  )
end

Given (/^I am on the edit venue page for venue "(.*?)"$/) do |item|
  venue = Venue.find_by(name: item)
  visit edit_venue_path(venue)
end

When (/^I select the Opening Time as "(.*?)"$/) do |time|
  select time, from: "venue_open_time"
end

When (/^I select the Closing Time as "(.*?)"$/) do |time|
  select time, from: "venue_close_time"
end

Then (/^I should be on the details page for venue "(.*?)"$/) do |item|
  venue = Venue.find_by(name: item)
  expect(current_path).to eq(venue_path(venue))
end

Then (/^I should be on the edit venue page for venue "(.*?)"$/) do |item|
  venue = Venue.find_by(name: item)
  expect(current_path).to eq(edit_venue_path(venue))
end
