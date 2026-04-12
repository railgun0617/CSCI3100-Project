# Line Coverage Report: coverage\index.html
# open coverage/index.html        # macOS
# xdg-open coverage/index.html    # Linux
# start coverage/index.html       # Windows

# bundle exec rubocop for style problems
# bundle exec rubocop -A for style autocorrect

# bundle exec rspec --format RspecHtmlFormatter --out rspec.html for Rspec coverage report
# RAILS_ENV=test bundle exec rspec for local test on Rspec CI

# COVERAGE=true bundle exec rspec for coverage report only in rspec
# COVERAGE=true bundle exec cucumber for coverage report only in cucumber



# bundle exec cucumber features/001.feature
Feature: Debugging

  As a developer
  So that I can debug easily
  I want to test here

  

  Scenario: Testing 1
    Given I am logged in as a staff
    Given the equipment "Projector" exists with 2 quantity
    Given the venue "Library" exists
    When I am on the manage resources page
    Then I should be on the manage resources page
    And I should see "Manage Resources"
    And I should see the equipment "Projector"
    And I should see the venue "Library"
    And I should see "Add Venue"
    And I should see "Edit"
    And I should see "Delete"

  Scenario: Testing 2
    Given I am logged in as a staff
    Given the venue "Library" exists
    When I am on the manage resources page
    Then I should see the venue "Library"
    When I am on the venue page
    Then I should see the venue "Library"
    When I am on the equipment and venue page
    Then I should see the venue "Library"

  Scenario: Testing 3
    Given I am logged in as a staff
    Given the equipment "Projector" exists with 2 quantity
    When I am on the manage resources page
    Then I should see the equipment "Projector"
    When I am on the equipment page
    Then I should see the equipment "Projector"
    When I am on the equipment and venue page
    Then I should see the equipment "Projector"
    