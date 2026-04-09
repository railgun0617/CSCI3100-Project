Given (/^the equipment "(.*?)" exists with (.*?) quantity$/) do |item, quantity|
  @equipment ||= {}
  @equipment[item] = Equipment.create(
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

When(/^I click the "(.*?)" button of the (.*?) "(.*?)"$/) do |button_text, item_type, item|
  # Find the row in the Equipment table that contains the equipment name
  row = all("tbody tr").find { |tr| tr.has_text?(item) }

  expect(row).to be_present, "Could not find a row for #{item_type} #{item}"

  within(row) do
    # Try clicking a button first
    if has_button?(button_text, wait: 0)
      click_button(button_text)
    # Otherwise fall back to link
    elsif has_link?(button_text, wait: 0)
      click_link(button_text)
    else
      raise "No button or link with text '#{button_text}' found in row for #{item}"
    end
  end
end

Then (/^I should be on the details page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  expect(current_path).to eq(equipment_path(equipment))
end

Then (/^I should be on the edit equipment page for equipment "(.*?)"$/) do |item|
  equipment = Equipment.find_by(name: item)
  expect(current_path).to eq(edit_equipment_path(equipment))
end