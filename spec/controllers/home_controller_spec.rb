# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
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

  describe 'GET index' do
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get :index
      end
    end

    context 'when user is signed in' do
      before do
        allow(controller).to receive(:current_user).and_return(@user)
      end

      it 'assigns @id to current_user email' do
        get :index
        expect(assigns(:id)).to eq(@user.email)
      end

      it 'see lastname in home page' do
        get :index
        expect(assigns(:current_user).lastname).to eq(@user.lastname)
      end

      it 'assigns @due_students with due students' do
        # Add due students
        Student.create(firstname: 'Due', lastname: 'Student', uin: '123456789', email: 'due@student.com',
                       classification: 'U1', major: 'CPSC', teacher: @user.email,
                       last_practice_at: Time.now, curr_practice_interval: 0)
        get :index
        expect(assigns(:due_students).count).to eq(3)
      end
    end

    describe '#stripYear' do
      it 'returns the last word of the string if the string has multiple words' do
        controller = HomeController.new
        expect(controller.strip_year('Spring 2023')).to eq('2023')
      end

      it 'returns the entire string if the string has only one word' do
        controller = HomeController.new
        expect(controller.strip_year('Spring')).to eq('Spring')
      end
    end

    describe '#getYears' do
      before do
        allow(controller).to receive(:current_user).and_return(@user)
      end

      it "returns the number of unique years in the teacher's courses" do
        get :index
        expect(controller.years).to eq(2)
      end
    end
  end
end
