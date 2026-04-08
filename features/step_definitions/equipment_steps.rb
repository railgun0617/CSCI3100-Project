Given (/^the equipment "(.*?)" exists with (.*?) quantity$/) do |item, quantity|
  @equipments ||= {}
  @equipments[item] = Equipment.create(
    name: item, description: "Description for #{item}", 
    location: "Location for #{item}", quantity: quantity.to_i, latitude: 22.418199, longitude: 114.207988
  )
end

Given (/^I am on the edit equipment page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  visit edit_equipment_path(equipment)
end

When (/^I select position with latitude: (.*?) and longitude: (.*?) on the map$/) do |latitude, longitude|
  page.execute_script("document.getElementById('equipment_latitude').value = #{latitude}")
  page.execute_script("document.getElementById('equipment_longitude').value = #{longitude}")
end

When (/^I click the "Delete" button of the equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  within("#equipment_#{equipment.id}") do
    click_button "Delete"
  end
end

Then (/^I should see the equipment "(.*?)" details$/) do |item|
  expect(page).to have_content(item)
  expect(page).to have_content("Description for #{item}")
  expect(page).to have_content("Location for #{item}")
  expect(page).to have_content("Quantity: 1")
end

Then (/^I should be on the details page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  expect(current_path).to eq(equipment_path(equipment))
end

Then (/^I should be on the edit equipment page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  expect(current_path).to eq(edit_equipment_path(equipment))
end