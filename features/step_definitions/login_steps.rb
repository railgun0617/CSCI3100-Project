Given(/^I type the (.*?) as "(.*?)"$/) do |field_name, value|
  fill_in field_name, with: value
end

Given("I have signed up as a student") do
  @student = create(:user, email: "1155123456@link.cuhk.edu.hk", password: "password123")
end

Given("I am logged in as a student") do
  @student = create(:user, email: "1155123456@link.cuhk.edu.hk", password: "password123")
  visit new_user_session_path
  fill_in "Email", with: @student.email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

Given("I am logged in as a staff") do
  @staff = create(:user, :staff, email: "staff@link.cuhk.edu.hk", password: "password123")
  visit new_user_session_path
  fill_in "Email", with: @staff.email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

