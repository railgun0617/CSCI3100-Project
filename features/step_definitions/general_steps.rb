Given(/^I am on the (.*) page$/) do |page_name|
  case page_name
  when 'main'
    visit root_path
  when 'sign in'
    visit new_user_session_path
  when 'sign up'
    visit new_user_registration_path
  else
    raise 'Unknown Page'
  end
end