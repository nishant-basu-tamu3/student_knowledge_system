# frozen_string_literal: true

Given('I am on the quiz page for student with existing id') do
  @student = Student.order('RANDOM()').first
  visit quiz_students_path(@student.id)
end

When('I select the correct student from the choices') do
  choose('answer', option: @student.id.to_s)
end
Then('the selected student should be different from the correct student') do
  selected_option = find('input[type="radio"]:checked', visible: false)
  expect(selected_option['id']).not_to eq(@student.id.to_s)
end
When('I select an incorrect student from the choices') do
  # Find all radio buttons
  radio_buttons = all('input[type="radio"]')

  # Find the first radio button with a non-integer ID
  incorrect_choice = radio_buttons.find { |rb| rb['id'].split('-').last.to_i.to_s != rb['id'].split('-').last }

  raise 'No incorrect choice found' unless incorrect_choice

  incorrect_choice.choose
end

When("I don't select any answer") do
  # Do nothing
end

When('I submit my answer') do
  click_button 'Submit'
end

Then('I should see that my answer is correct') do
  expect(page).to have_content('Correct Answer!')
end

Then('I should see that my answer is incorrect') do
  expect(page).to have_content('Incorrect')
end

Then('I should not see any feedback about correctness') do
  expect(page).not_to have_content('Correct Answer!')
  expect(page).not_to have_content('Incorrect Answer')
end

Then("the student's practice interval should be doubled") do
  oldInterval = @student.curr_practice_interval.to_i
  newInterval = oldInterval * 2
  @student.reload
  expect(@student.curr_practice_interval.to_i).to eq(newInterval)
end

Then("the student's practice interval should be halved if it was greater than 15") do
  oldInterval = @student.curr_practice_interval.to_i
  @student.reload
  if @student.curr_practice_interval.to_i > 15
    expect(@student.curr_practice_interval.to_i).to eq(oldInterval / 2)
  else
    expect(@student.curr_practice_interval.to_i).to eq(oldInterval)
  end
end

Then("the student's practice interval should remain unchanged") do
  oldInterval = @student.curr_practice_interval.to_i
  @student.reload
  expect(@student.curr_practice_interval.to_i).to eq(oldInterval)
end

Then("the student's last practice time should be updated") do
  @student.reload
  expect(@student.last_practice_at).to be_within(1.minute).of(Time.now)
end

Then("the student's last practice time should remain unchanged") do
  lastPrac = @student.last_practice_at
  @student.reload
  expect(@student.last_practice_at).to be_within(1.minute).of(lastPrac)
end
