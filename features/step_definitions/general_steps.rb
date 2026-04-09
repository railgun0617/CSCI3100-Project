Given(/^I am on the (.*?) page$/) do |page_name|
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
  else
    raise 'Unknown Page'
  end
end

When(/^I click the "(.*?)" button$/) do |button_text|
  click_button button_text
end

When(/^I click the "(.*?)" link$/) do |link_text|
    click_link link_text
end

Then(/^I should( not)? see(?: the (.*?))? "(.*?)"$/) do |negation, message_type, message|
  if negation
    expect(page).not_to have_content(message)
  else
    expect(page).to have_content(message)
  end
end
