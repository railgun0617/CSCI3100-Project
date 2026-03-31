# The scenarios have not yet been 
Feature: Sign Up and Sign in page
  
  As a student
  So that I can book equipment and venues
  I want to sign up an account and sign in

  Scenario: Successful Registerion
    Given I am on sign up page
    When I type the email as "1155123456@link.cuhk.edu.hk"
    And I type my password as "qwerty123"
    And I type my password confirmation as "qwerty123"
    And I click the button "Sign Up"
    Then it should show "Successful Registeration"

  Scenario: Mismatch Password Confirmation
    Given I am on the sign up page
    When I type the email as "1155123456@link.cuhk.edu.hk"
    When I type the password as "qwerty123"
    And I type the password confirmation as "qwertt123"
    And I click the button "Sign Up"
    Then it should popa warning message "Password confirmation doesn't match Password"

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
    