Given(/^I am on the (.*) page$/) do |page_name|
  case page_name
  when 'main'
    visit root_path
  when 'sign in'
    visit new_user_session_path
  when 'sign up'
    visit new_user_registration_path
  when 'edit account'
    visit edit_user_registration_path
  when 'equipment'
    visit equipment_index_path
  when 'venue'
    visit venues_path
  when 'equipment and venue'
    visit resources_path
  when 'booking'
    visit bookings_path
  when 'manage resources'
    # if !current_user.staff?
    #   raise 'Only staff can manage resources' and return
    # end
    visit manage_resources_path\
  when 'create staff'
    visit new_admin_user_path
  else
    raise 'Unknown Page'
  end
end

Given(/^I am a (.*)$/) do |user_type|
  role = user_type.strip.downcase
  unless %w[student staff].include?(role)
    raise "Unknown User Type: #{user_type}"
  end

  @current_user = User.find_or_initialize_by(email: "#{role}@example.com")
  @current_user.password = 'Password123'
  @current_user.password_confirmation = 'Password123'
  @current_user.role = role
  @current_user.save!

  visit new_user_session_path
  fill_in 'Email', with: @current_user.email
  fill_in 'Password', with: 'Password123'
  click_button 'Log in'
end

When (/^I press (.*?)$/) do |button_text|
  click_button button_text
end

Then (/^I should see(?: the (.*?))? "(.*?)"$/) do |message_type, message|
  expect(page).to have_content(message)
end
