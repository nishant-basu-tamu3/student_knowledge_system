Feature: User signs in with Google

Scenario: Successful authentication and user exists
    Given a user exists with the email "testuser@example.com"
    When I attempt to sign in with Google as "testuser@example.com"
    Then I should be redirected to the magic link for "testuser@example.com"

Scenario: Successful authentication but user does not exist
    Given no user exists with the email "newuser@example.com"
    When I attempt to sign in with Google as "newuser@example.com"
    Then I should be redirected to the account creation page
    And I should see "Create an account before signing in with Google"

Scenario: Failed authentication with Google
    When I attempt to sign in with Google and it fails
    Then I should be redirected to the home page
