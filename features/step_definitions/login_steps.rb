Given(/^I fill in the (.*?) as "(.*?)"$/) do |field_name, value|
  fill_in field_name, with: value
end

Given(/^I select "([^"]*)"$/) do |option|
  select option, from: "Department"
end


Given("I have signed up as a student") do
  @student = create(:user, email: "1155123456@link.cuhk.edu.hk", password: "password123")
end

Given("I am logged in as a student") do
  logout(:user) rescue Warden.test_reset!
  tenant = Tenant.find_or_create_by!(name: "Department of Computer Science and Engineering")
  @student = User.find_or_create_by!(email: "1155123456@link.cuhk.edu.hk") do |u|
    u.password = "password123"
    u.role = :student
    u.tenant = tenant
  end
  login_as(@student, scope: :user)
end

Given("I am logged in as a staff") do
  logout(:user) rescue Warden.test_reset!
  tenant = Tenant.find_or_create_by!(name: "Department of Computer Science and Engineering")
  @staff = User.find_or_create_by!(email: "staff@link.cuhk.edu.hk") do |u|
    u.password = "password123"
    u.role = :staff
    u.tenant = tenant
  end
  login_as(@staff, scope: :user)
end

Given("I am logged in as an admin") do
  logout(:user) rescue Warden.test_reset!
  tenant = Tenant.find_or_create_by!(name: "Admin")
  @staff = User.find_or_create_by!(email: "admin@link.cuhk.edu.hk") do |u|
    u.password = "password123"
    u.role = :staff
    u.tenant = tenant
  end
  login_as(@staff, scope: :user)
end
