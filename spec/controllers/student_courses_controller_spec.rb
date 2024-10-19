# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentCoursesController, type: :controller do
  before :each do
    @user = User.create(email: 'student@gmail.com', firstname: 'Alice', lastname: 'Bob',
                        department: 'computer science', confirmed_at: Time.now)

    @course1 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                             semester: 'Spring 2023')
    @course2 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                             semester: 'Fall 2023')
    @course3 = Course.create(course_name: 'CSCE 412', teacher: 'student@gmail.com', section: '501',
                             semester: 'Spring 2024')

    @student1 = Student.create(firstname: 'Zebulun', lastname: 'Oliphant', uin: '734826482', email: 'zeb@tamu.edu',
                               classification: 'U2', major: 'CPSC', teacher: 'student@gmail.com',
                               last_practice_at: Time.now)
    @student2 = Student.create(firstname: 'Webulun', lastname: 'Woliphant', uin: '734826483', email: 'web@tamu.edu',
                               classification: 'U2', major: 'CPSC', teacher: 'student@gmail.com',
                               last_practice_at: Time.now)
  end

  describe '#update' do
    it 'redirects to sign in page' do
      get :update, params: { id: @student1.id, student_course: 'A' }
      expect(redirect_to(student_url(@student1)))
    end
  end

  describe '#destroy' do
    it 'deletes the course' do
      get :destroy, params: { id: @student2.id }
      expect(redirect_to(student_url(@student2)))
    end

    #   it 'returns the entire string if the string has only one word' do
    #     controller = HomeController.new
    #     expect(controller.stripYear('Spring')).to eq('Spring')
    #   end
  end
end
