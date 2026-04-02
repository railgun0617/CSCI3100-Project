Given (/^I type the (.*?) as "(.*?)"$/) do |field_name, value|
  field_name = "user[#{field_name.gsub(' ', '_')}]"
  fill_in field_name, with: value
end

When(/^I click the "(.*?)" button$/) do |button_text|
  click_button button_text
end

Then (/^it should pop "(.*?)" error message$/) do |error_message|
  expect(page).to have_content(error_message)
end