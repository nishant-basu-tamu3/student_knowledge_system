# frozen_string_literal: true

Given('a user exists with the email {string}') do |email|
  @user = User.create!(email:)
end

Given('no user exists with the email {string}') do |email|
  User.find_by(email:)&.destroy
end

When('I attempt to sign in with Google as {string}') do |email|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                       'provider' => 'google_oauth2',
                                                                       'info' => { 'email' => email }
                                                                     })
  visit '/auth/google_oauth2/callback'
end

When('I attempt to sign in with Google and it fails') do
  OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  visit '/auth/google_oauth2/callback'
end

Then('I should be redirected to the magic link for {string}') do |email|
  user = User.find_by(email:)
  session = Passwordless::Session.find_by(authenticatable: user)
  send(Passwordless.mounted_as).token_sign_in_url(session.token)
  expect(current_path).to eq('/home')
end

Then('I should be redirected to the account creation page') do
  expect(page).to have_current_path(new_user_path)
end

Then('I should be redirected to the home page') do
  expect(page).to have_current_path('/')
end
