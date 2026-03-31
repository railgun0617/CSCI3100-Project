# The scenarios have not yet been 
Feature: Login page
  
  As a student
  So that I can book equipment and venues
  I want to register an account and login

  Scenario: Successful Registerion
    Given I am on sign up page
    When I type all the information correctly
    Then it should show "Successful Registeration"

  Scenario: Successful Login
    Given I am on the sign in page
    When I type all the information correctly
    Then it should show "Successful Login"

  Scenario: Correct Email
    Given I am on the sign in page
    And I type the email as "1155123456@link.cuhk.edu.hk"
    When I press "Submit" button
    Then it should not pop a warning
    
  Scenario: Incorrect Email
    Given I am on the sign in page
    Given I type the email as "1155123456link.cuhk.edu.hk"
    When I press "Submit" button
    Then It should pop a warning
    