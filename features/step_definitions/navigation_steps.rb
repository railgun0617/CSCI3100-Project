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
    when 'my bookings' then bookings_path
    else raise 'Unknown page'
    end
  expect(page).to have_current_path(expected_path)
end