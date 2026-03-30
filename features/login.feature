Feature: Login page
  
  As a student
  So that I can book equipment and venues
  I want to register an account and login

  Scenario: Successful Registerion
    Given I am on login page
    When I type all the information correctly
    Then it should show "Success Registeration"

  Scenario: Correct Email
    Given I type the email as "1155123456@link.cuhk.edu.hk"
    When I press "Submit" button
    Then it should not pop a warning
    
  Scenario: Incorrect Email
    Given I type the email as "1155123456@link.ust.edu.hk"
    When I press "Submit" button
    Then It should pop a warning

  Scenario: 

    