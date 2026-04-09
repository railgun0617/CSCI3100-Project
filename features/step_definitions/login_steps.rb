Given(/^I type the (.*?) as "(.*?)"$/) do |field_name, value|
  fill_in field_name, with: value
end

Given("I have signed up as a student") do
  @student = create(:user, email: "1155123456@link.cuhk.edu.hk", password: "password123")
end

Given("I am logged in as a student") do
  logout(:user) rescue Warden.test_reset!
  @student = User.find_or_create_by!(email: "1155123456@link.cuhk.edu.hk") do |u|
    u.password = "password123"
    u.role = :student
  end
  login_as(@student, scope: :user)
end

Given("I am logged in as a staff") do
  logout(:user) rescue Warden.test_reset!
  @staff = User.find_or_create_by!(email: "staff@link.cuhk.edu.hk") do |u|
    u.password = "password123"
    u.role = :staff
  end
  login_as(@staff, scope: :user)
end

