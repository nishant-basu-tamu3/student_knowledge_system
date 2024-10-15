# frozen_string_literal: true

When('I go to the students page') do
  visit students_path
  expect(page).to have_content('New student')
end

Then('I select {string} under semester') do |string|
  find('#selected_semester').select(string)
end

Then('I submit the form') do
  find("[value='Filter Students List']").click
  expect(page).to have_content('Kunal')
end

When('I click show this student') do
  expect(page).to have_selector('button', text: 'Show this student')
  first('button', text: 'Show this student').click
end

When('I fill in student {string} with {string}') do |string, string2|
  fill_in "student[#{string}]", with: string2
  expect(find_field("student[#{string}]").value).to eq(string2)
end

When('I select {string} under tag') do |string|
  find('#selected_tag').select(string)
  expect(find('#selected_tag').value).to eq(string)
end

When('I fill in the first student course {string} with {string}') do |string, string2|
  # fill_in "student_course[#{string}]", with: string2
  all("input[name='student_course[#{string}]']").first.fill_in with: string2
end
