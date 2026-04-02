Given (/^the venue "(.*?)" exists$/) do |item|
  @venue = Venue.create(name: item, description: "Description for #{item}", 
                         capacity: "Capacity for #{item}")
end

Then (/^I should see the venue "(.*?)"$/) do |item|
  expect(page).to have_content(item)
end