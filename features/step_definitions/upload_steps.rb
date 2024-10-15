# frozen_string_literal: true

Given('I am on the upload page') do
  visit upload_index_path
  expect(page).to have_content 'Upload Instructions'
end

When('I upload a zip file') do
  attach_file('file', './app/resources/ProfRitchey_Template.zip')
end

When('I input form information') do
  fill_in('course_temp', with: 'CSCE 606')
  fill_in('section_temp', with: '000')
  fill_in('semester_temp', with: 'Fall 2022')
end

When('I click save') do
  click_button('Save')
end

Then('I should see the upload was successful') do
  expect(page).to have_content 'Upload successful!'
end

When('I upload a zip file with .display files') do
  attach_file('file', './app/resources/431_image_roster_with_chrome_files.zip')
end

When('I input 431 form information') do
  fill_in('course_temp', with: 'CSCE 431')
  fill_in('section_temp', with: '550')
  fill_in('semester_temp', with: 'Spring 2023')
end

When('I create account and sign in as {string}') do |email|
  visit root_path
  click_link('Create Account')
  fill_in('user_email', with: email)
  click_button('Create account')
  expect(page).to have_content('Your account has been created. Please sign in.')
  click_link('Create Account')
  fill_in('user_email', with: email)
  click_button('Create account')
  expect(page).to have_content('Your account already exists. Please sign in.')
  click_link('Sign in')
  fill_in('passwordless_email', with: email)
  click_button('Send magic link') # email does not get sent or given to action mailer deliveries array
  expect(page).to have_content('If we have found you in our system, you have been sent a link to log in!')

  user = User.find_by(email:)
  session = Passwordless::Session.new({
                                        authenticatable: user,
                                        user_agent: 'Command Line',
                                        remote_addr: 'unknown'
                                      })
  session.save!
  @magic_link = send(Passwordless.mounted_as).token_sign_in_url(session.token)

  visit @magic_link.to_s
  expect(page).to have_content('Howdy')
  expect(page).to have_content('Welcome Back!')
end
