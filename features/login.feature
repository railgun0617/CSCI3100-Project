Feature: Sign Up and Sign In page
  
  As a student
  So that I can book equipment and venues
  I want to sign up an account and sign in



# Sign Up Page

  Scenario: Successful Registerion
    Given I am on the sign up page
    And I type the Email as "1155123456@link.cuhk.edu.hk"
    And I type the Password as "qwerty123"
    And I type the Password confirmation as "qwerty123"
    When I click the "Sign Up" button
    Then it should show "Successful Registeration"

  Scenario: Blank Email and Password
    Given I am on the sign up page
    When I click the "Sign Up" button
    Then I should see the error message "Email can't be blank"
    And I should see the error message "Password can't be blank"

  Scenario: Mismatch Password Confirmation
    Given I am on the sign up page
    And I type the Email as "1155123456@link.cuhk.edu.hk"
    And I type the Password as "qwerty123"
    And I type the Password confirmation as "qwertt123"
    When I click the "Sign Up" button
    Then I should see the error message "Password confirmation doesn't match Password"

  Scenario: Password Too Short
    Given I am on the sign up page
    And I type the Email as "1155123456@link.cuhk.edu.hk"
    And I type the Password as "156"
    And I type the Password confirmation as "156"
    When I click the "Sign Up" button
    Then I should see the error message "Password is too short (minimum is 6 characters)"



# Sign In Page

  Scenario: Successful Login
    Given I am on the sign in page
    And I type all the information correctly
    When I click the "Log In" button
    Then it should show "Successful Login"

#  Scenario: Correct Email
#    Given I am on the sign in page
#    And I type the Email as "1155123456@link.cuhk.edu.hk"
#    When I click the "Log In" button
#    Then it should not pop a warning
    
#  Scenario: Incorrect Email or Password
#    Given I am on the sign in page
#    And I type the Email as "1155123456link.cuhk.edu.hk"
#    When I click the "Log In" button
#    Then It should pop a warning
    