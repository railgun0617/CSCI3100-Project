Given (/^the venue "(.*?)" exists$/) do |item|
  @venue ||= {}
  @venue[item] = Venue.create(
    name: item, description: "Description for #{item}",
    capacity: "Capacity for #{item}", open_time: "09:00", close_time: "17:00",
    latitude: 22.418199, longitude: 114.207988
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