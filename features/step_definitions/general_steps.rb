Given(/^I am on the (.*) page$/) do |page_name|
  case page_name
  when 'main'
    visit root_path
  when 'sign in'
    visit new_user_session_path
  when 'sign up'
    visit new_user_registration_path
  when 'equipment'
    visit equipment_index_path
  when 'venue'
    visit venues_path
  when 'equipment and venue'
    visit resources_path
  when 'booking'
    visit bookings_path
  else
    raise 'Unknown Page'
  end
end