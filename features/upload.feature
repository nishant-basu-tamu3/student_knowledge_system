Feature: Upload a batch of students and a course with Howdy zip file

As a professor,
So I can input data quickly
I want to be able to upload a file from howdy to input students and a course


Scenario: Upload correctly
    When I create account and sign in as "team_cluck_admin2@gmail.com"
    Given I am on the upload page
    When I upload a csv file
    And I upload a complete webpage file
    And I input form information
    When I click save
    Then I should see the upload was successful

Scenario: Upload with .display files correctly
    When I create account and sign in as "team_cluck_admin2@gmail.com"
    Given I am on the upload page
    When I upload a csv file
    And I upload a complete webpage file
    And I input 431 form information
    When I click save
    Then I should see the upload was successful