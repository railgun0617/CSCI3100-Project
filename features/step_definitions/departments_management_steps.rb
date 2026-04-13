Given(/^the department "(.*?)" exists with a slug "(.*?)"$/) do |department_name, slug_name|
  Tenant.create!(name: department_name, slug: slug_name)
end

Given (/^the department "(.*?)" exists with a user$/) do |department_name|
  tenant = Tenant.find_or_create_by!(name: department_name)
  User.create!(email: "test@example.com", password: "password", tenant: tenant)
end

Then(/^I should find "(.*?)" before "(.*?)"$/) do |first, second|
  names = all("table tbody tr td:first-child").map(&:text)

  first_index = names.index(first)
  second_index = names.index(second)

  expect(first_index).not_to be_nil, "Could not find '#{first}' in the department list"
  expect(second_index).not_to be_nil, "Could not find '#{second}' in the department list"

  expect(first_index).to be < second_index,
    "Expected '#{first}' to appear before '#{second}', but it did not"
end
