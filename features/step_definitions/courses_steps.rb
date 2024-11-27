# frozen_string_literal: true

Given(/the following users exist/) do |users_table|
  users_table.hashes.each do |user|
    User.create user
  end
end

Given(/the following courses exist/) do |courses_table|
  courses_table.hashes.each do |course|
    Course.create course
  end
end

Given(/the following students exist/) do |students_table|
  students_table.hashes.each do |student|
    Student.create student
  end
end

Given(/students are enrolled in their respective courses/) do
  StudentCourse.create(course_id: Course.find_by(course_name: 'CSCE 411', semester: 'Fall 2022', section: '501').id,
                       student_id: Student.find_by(uin: '734826482').id, final_grade: '100')
  StudentCourse.create(course_id: Course.find_by(course_name: 'CSCE 411', semester: 'Fall 2022', section: '501').id,
                       student_id: Student.find_by(uin: '926409274').id, final_grade: '')
  StudentCourse.create(
    course_id: Course.find_by(course_name: 'CSCE 411', semester: 'Spring 2023',
                              section: '501').id, student_id: Student.find_by(uin: '274027450').id, final_grade: ''
  )
  StudentCourse.create(
    course_id: Course.find_by(course_name: 'CSCE 411', semester: 'Spring 2023',
                              section: '501').id, student_id: Student.find_by(uin: '720401677').id, final_grade: ''
  )
  StudentCourse.create(
    course_id: Course.find_by(course_name: 'CSCE 412', semester: 'Spring 2023',
                              section: '501').id, student_id: Student.find_by(uin: '734826482').id, final_grade: ''
  )
  StudentCourse.create(
    course_id: Course.find_by(course_name: 'CSCE 412', semester: 'Spring 2023',
                              section: '501').id, student_id: Student.find_by(uin: '983650274').id, final_grade: ''
  )
end

When('I sign in as {string}') do |email|
  visit root_path
  # click_link("Create Account")
  # fill_in("user_email", with: email)
  # click_button("Create account")
  # expect(page).to have_content("Your account has been created. Please sign in.")
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

  ## og thing
  # visit new_user_session_path()
  # fill_in("Email", with: "team_cluck_admin@gmail.com")
  # fill_in("Password", with: "team_cluck_12345!")
  # click_button("Log in")
end

When(/I go to the courses page/) do
  visit courses_path
end

Then('I should see {string} offered in {string}') do |course_name, semester|
  has_course = false
  all('tr').each do |tr|
    next unless tr.has_content?(course_name)
    next unless tr.has_content?(semester)

    has_course = true
  end
  expect(has_course).to eq(true)
end

When('I fill in {string} with {string}') do |search, query|
  fill_in(search, with: query)
end

When('I click {string}') do |button|
  click_button(button)
end

When('I click the first {string}') do |button|
  first(:button, button.to_s).click
end

Then('I should not see {string} offered in {string}') do |course_name, semester|
  has_course = false
  all('tr').each do |tr|
    next unless tr.has_content?(course_name)
    next unless tr.has_content?(semester)

    has_course = true
  end
  expect(has_course).to eq(false)
end

And('I select {string} under the semester dropdown') do |semester|
  semester_dropdown = find('#selected_semester')
  semester_dropdown_options = semester_dropdown.all('option')
  semester_dropdown_options.each do |option|
    puts option.text
  end

  # Find the dropdown menu
  dropdown = find('#selected_semester')

  # Check that the dropdown menu is visible and enabled
  raise 'Semester dropdown is not visible' unless dropdown.visible?

  # Select the option from the dropdown menu
  select semester, from: 'selected_semester'
end

When('I visit a course page with an invalid course ID in HTML format') do
  visit '/courses/9999' # Assuming 9999 is an invalid ID
end

When('I visit a course page with an invalid course ID in JSON format') do
  page.driver.header 'Accept', 'application/json'
  visit '/courses/9999'
end

Then('I should be redirected to the courses page with a "Given course not found." notice') do
  expect(page).to have_current_path(courses_path)
  expect(page).to have_content('Given course not found.')
end

Then('I should receive a "204 No Content" JSON response') do
  expect(page.status_code).to eq(204)
  expect(page.body).to be_empty
end
