Given(/^I type the (.*?) as "(.*?)"$/) do |field_name, value|
  fill_in field_name, with: value
end

Given("I have signed up as a student") do
  @student = create(:user, email: "1155123456@link.cuhk.edu.hk", password: "password123")
end

Given("I am logged in as a student") do
  @current_user = create(:user, :student, email: "1155123456@link.cuhk.edu.hk", password: "password123")
  login_as(@current_user, scope: :user)
end

Given("I am logged in as a staff") do
  @current_user = create(:user, :staff, email: "staff@link.cuhk.edu.hk", password: "password123")
  login_as(@current_user, scope: :user)
end

