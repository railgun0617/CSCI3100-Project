Given(/^I am on the (.*) page$/) do |page_name|
  case page_name
  when 'main'
    visit root_path
  when 'login'
    visit login_path
  else
    raise 'Unknown Page'
  end
end

When(/^I click '(.*)'$/) do |link_text|
    click_link link_text
end

Then(/^I should be on the (.*) page$/) do |page_name|
  expected_path =
    case page_name
    when 'login' then login_path
    when 'main'  then root_path
    else raise 'Unknown page'
    end
  expect(page).to have_current_path(expected_path)
end