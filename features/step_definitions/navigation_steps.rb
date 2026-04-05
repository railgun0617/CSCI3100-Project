When(/^I click '(.*)'$/) do |link_text|
    click_link link_text
end

Then(/^I should be on the (.*) page$/) do |page_name|
  expected_path =
    case page_name
    when 'main'  then root_path
    when 'sign in' then new_user_session_path
    when 'sign up' then new_user_registration_path
    when 'edit account' then edit_user_registration_path
    when 'equipment and venue' then resources_path
    else raise 'Unknown page'
    end
  expect(page).to have_current_path(expected_path)
end