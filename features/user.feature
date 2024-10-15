Feature: Create user and see welcome message

Feature: Create account redirect at the login page
As a professor
When I don't have an account, and I click Create account
Redirect to the Create Account page
I should see text fields for Name, Mail ID, and Department.
I create account and then sign in to see my lastname

Background: database

Given the following users exist:
| email                         | firstname                  | lastname                   | department                 | confirmed_at               |
| team_cluck_admin@gmail.com    | alice                      | bob                        | computer science           | 2023-01-19 12:12:07.544080 |

Scenario: Welcome Message
    When I sign in as "team_cluck_admin@gmail.com"
    Then I should see "Howdy Professor bob!"