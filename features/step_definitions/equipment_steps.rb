Given (/^the equipment "(.*?)" exists with (.*?) quantity$/) do |item, quantity|
  tenant = Tenant.find_or_create_by!(name: "Department of Computer Science and Engineering")
  @equipments ||= {}
  @equipments[item] = Equipment.create!(
    name: item, description: "Description for #{item}", tenant: tenant,
    location: "Location for #{item}", quantity: quantity.to_i, latitude: 22.418199, longitude: 114.207988
  )
end

Given(/^the equipment "(.*?)" exists with desciption "(.*?)" and location "(.*?)" and department "(.*?)"$/) do |item, description, location, department|
  tenant = Tenant.find_or_create_by!(name: department)
  @equipments ||= {}
  @equipments[item] = Equipment.create!(
    name: item,
    description: description,
    location: location,
    tenant: tenant,
    quantity: 1,
    latitude: 22.418199,
    longitude: 114.207988
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

Then (/^I should be on the details page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  expect(current_path).to eq(equipment_path(equipment))
end

Then (/^I should be on the edit equipment page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  expect(current_path).to eq(edit_equipment_path(equipment))
end
