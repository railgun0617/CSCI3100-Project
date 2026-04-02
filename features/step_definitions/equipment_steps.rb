Given (/^the equipment "(.*?)" exists$/) do |item|
  @equipment = Equipment.create(name: item, description: "Description for #{item}", 
                                location: "Location for #{item}", quantity: 1)
end

Then (/^I should see the equipment "(.*?)"$/) do |item|
  expect(page).to have_content(item)
end