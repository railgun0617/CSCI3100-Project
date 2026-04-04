Given(/^I type the (.*?) as "(.*?)"$/) do |field_name, value|
  fill_in field_name, with: value
end

When(/^I click the "(.*?)" button$/) do |button_text|
  click_button button_text
end