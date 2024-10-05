# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  describe '#controller' do
    before do
      @user = User.create(email: 'student@gmail.com', confirmed_at: Time.now)
      # authenticate_by_session(@user)
      allow(controller).to receive(:current_user).and_return(@user)
      @course1 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                               semester: 'Spring 2023')
      @course2 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                               semester: 'Fall 2023')
      @course3 = Course.create(course_name: 'CSCE 412', teacher: 'student@gmail.com', section: '501',
                               semester: 'Spring 2024')

      @student = Student.create(firstname: 'Zebulun', lastname: 'Oliphant', uin: '734826482', email: 'zeb@tamu.edu',
                                classification: 'U2', major: 'CPSC', teacher: 'student@gmail.com')
    end

    it 'calls index successfully' do
      get :index, params: { id: @student }
      expect(response).to have_http_status(:successful)
    end

    it 'shows successfully' do
      get :show, params: { id: @student.id }
      expect(response).to have_http_status(:successful)
    end

    it 'creates a new student' do
      # should be 1 once signing in works
      expect do
        post :create, params: { student: {
          firstname: 'John',
          lastname: 'Doe',
          uin: '123456789',
          email: 'johndoe@example.com',
          classification: 'U1',
          major: 'CPSC',
          teacher: 'team_cluck_admin@gmail.com'
        } }
      end.to change(Student, :count).by(1)
    end

    it 'updates successfully' do
      get :show, params: { id: @student.id }
    end

    it 'deletes successfully' do
      get :show, params: { id: @student.id }
    end
  end

  describe '#quiz' do
    before do
      @user = User.create(email: 'teacher@gmail.com', confirmed_at: Time.now)
      allow(controller).to receive(:current_user).and_return(@user)
      
      @student = Student.create(
                                firstname: 'Zebulun',
                                lastname: 'Oliphant',
                                uin: '734826482',
                                email: 'zeb@tamu.edu',
                                classification: 'U2',
                                major: 'CPSC',
                                teacher: 'teacher@gmail.com',
                                curr_practice_interval: '10',
                                last_practice_at: Time.now # Ensure this is set
                              )

      # Creating additional students to sample from
      7.times do |i|
        Student.create(firstname: "Student#{i}", lastname: "Test#{i}", uin: "12345#{i}", email: "student#{i}@example.com",
                       classification: 'U2', major: 'CPSC', teacher: 'teacher@gmail.com', curr_practice_interval: '10', last_practice_at: Time.now)
      end
    end

    context 'when answer is correct' do
      it 'doubles the current practice interval' do
        expect {
          get :quiz, params: { id: @student.id, answer: @student.id }
        }.to change { @student.reload.curr_practice_interval.to_i }.by(10)
        
        expect(assigns(:correctAnswer)).to be true
      end
    end

    context 'when answer is incorrect' do
      it 'halves the current practice interval if it is greater than 15' do
        @student.update(curr_practice_interval: '30')
        
        expect {
          get :quiz, params: { id: @student.id, answer: 'wrong_id' }
        }.to change { @student.reload.curr_practice_interval.to_i }.by(-15)
        
        expect(assigns(:correctAnswer)).to be false
      end

      it 'does not change the current practice interval if it is 15 or less' do
        @student.update(curr_practice_interval: '10')
        
        expect {
          get :quiz, params: { id: @student.id, answer: 'wrong_id' }
        }.not_to change { @student.reload.curr_practice_interval.to_i }

        expect(assigns(:correctAnswer)).to be false
      end
    end

    context 'when no answer is provided' do
      it 'sets correctAnswer to nil' do
        get :quiz, params: { id: @student.id, answer: nil }
        expect(assigns(:correctAnswer)).to be false
      end
    end
  end
  describe '#index' do
    before do
      @user = User.create(email: 'teacher@gmail.com', confirmed_at: Time.now)
      allow(controller).to receive(:current_user).and_return(@user)

      @course1 = Course.create(course_name: 'CSCE 411', teacher: 'teacher@gmail.com', section: '501', semester: 'Spring 2023')
      @course2 = Course.create(course_name: 'CSCE 411', teacher: 'teacher@gmail.com', section: '501', semester: 'Fall 2023')

      @student1 = Student.create(
        firstname: 'Alice',
        lastname: 'Smith',
        uin: '123456789',
        email: 'alice@example.com',
        classification: 'U2',
        major: 'CPSC',
        teacher: 'teacher@gmail.com'
      )
      @student2 = Student.create(
        firstname: 'Bob',
        lastname: 'Johnson',
        uin: '987654321',
        email: 'bob@example.com',
        classification: 'U2',
        major: 'CPSC',
        teacher: 'teacher@gmail.com'
      )

      StudentCourse.create(student_id: @student1.id, course_id: @course1.id) # Alice enrolled in CSCE 411
      # Uncomment the next line if you want to enroll Bob in a different course
      # StudentCourse.create(student_id: @student2.id, course_id: @course2.id) # Bob enrolled in CSCE 412

      @params = { selected_course: @course1.course_name, selected_semester: @course1.semester }
    end

    it 'displays only students enrolled in the selected course and semester' do
      get :index, params: @params
      expect(assigns(:students)).not_to include(@student2)  # Bob should not be included
    end
    
    it 'calls index successfully' do
      get :index
      expect(response).to have_http_status(:success)
    end

    context 'when filtering by tag' do
      before do
        @tag = Tag.create(tag_name: 'Excellent', teacher: 'teacher@gmail.com')
        StudentsTag.create(student_id: @student1.id, tag_id: @tag.id, teacher: 'teacher@gmail.com')
      end

      it 'does not include students without the selected tag' do
        get :index, params: { selected_tag: 'Nonexistent Tag' }
        
        expect(assigns(:students)).not_to include(@student1)
        expect(assigns(:students)).not_to include(@student2)
      end
    end
  end
end


