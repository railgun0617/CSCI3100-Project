def visit_page(page_name)
  case page_name
  when 'main'
    visit root_path
  when 'sign in'
    visit new_user_session_path
  when 'sign up'
    visit new_user_registration_path
  when 'edit account'
    visit edit_user_registration_path
  when 'create staff'
    visit new_admin_user_path
  when 'equipment'
    visit equipment_index_path
  when 'add equipment'
    visit new_equipment_path
  when 'venue'
    visit venues_path
  when 'add venue'
    visit new_venue_path
  when 'equipment and venue'
    visit resources_path    
  when 'booking'
    visit bookings_path
  when 'my bookings'
    visit bookings_path
  when 'manage resources'
    visit manage_resources_path
  when 'staff dashboard'
    visit staff_dashboard_path
  when 'manage departments'
    visit admin_tenants_path
  else
    raise 'Unknown Page'
  end
end

Given(/^I am on the (.*?) page$/) do |page_name|
  visit_page(page_name)
end

When(/^I visit the (.*?) page$/) do |page_name|
  visit_page(page_name)
end

When(/^I click the "(.*?)" button$/) do |button_text|
  click_button button_text
end

When(/^I click the "(.*?)" link$/) do |link_text|
  click_link link_text
end

When(/^I click the "(.*?)" button of the (.*?) "(.*?)"$/) do |button_text, item_type, item_name|
  row = find("table tbody tr", text: item_name)

  expect(row).to be_present, "Could not find a row for #{item_type} #{item_name}"

  within(row) do
    click_link_or_button(button_text)
  end
end

When(/^I type "(.*?)" in search bar$/) do |term|
  fill_in "q[name_or_description_or_location_cont]", with: term
  click_button "Search"
end

Then(/^I should( not)? see(?: the (.*?))? "(.*?)"$/) do |negation, message_type, message|
  if negation
    expect(page).not_to have_content(message)
  else
    expect(page).to have_content(message)
  end
end

Then(/^I should be on the (.*?) page$/) do |page_name|
  expected_path =
    case page_name
    when 'main'  then root_path
    when 'sign in' then new_user_session_path
    when 'sign up' then new_user_registration_path
    when 'edit account' then edit_user_registration_path
    when 'equipment' then equipment_index_path
    when 'add equipment' then new_equipment_path
    when 'venue' then venues_path
    when 'add venue' then new_venue_path
    when 'equipment and venue' then resources_path
    when 'manage resources' then manage_resources_path
    when 'staff dashboard' then staff_dashboard_path
    when 'manage departments' then admin_tenants_path
    when 'my bookings' then bookings_path
    else raise 'Unknown page'
    end
  expect(page).to have_current_path(expected_path)
end
