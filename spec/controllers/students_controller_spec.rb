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

      @student = Student.create(firstname: 'Zebulun', lastname: 'Oliphant', uin: '734826482',
                                email: 'zeb@tamu.edu', classification: 'U2', major: 'CPSC',
                                teacher: 'student@gmail.com', notes: 'Good Student!')
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

    it 'redirects with a notice when student with the UIN already exists' do
      post :create, params: { student: {
        firstname: 'New',
        lastname: 'Student',
        uin: @student.uin,
        email: 'new@example.com',
        classification: 'U2',
        major: 'CPSC',
        teacher: 'student@gmail.com'
      } }

      expect(response).to redirect_to(students_url)
      expect(flash[:notice]).to eq('Student with the UIN was already created.')
    end

    it 'updates successfully' do
      get :show, params: { id: @student.id }
    end

    it 'deletes successfully' do
      get :show, params: { id: @student.id }
    end

    it 'retrieves notes successfully' do
      get :notes, params: { id: @student.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq({ 'notes' => @student.notes })
    end

    it 'updates notes successfully' do
      new_notes = 'Updated Notes!'
      patch :update_notes, params: { id: @student.id, notes: new_notes }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq({ 'success' => true })
      @student.reload
      expect(@student.notes).to eq(new_notes)
    end

    it 'handles notes update failure' do
      # Assuming your Student model validates presence of notes
      @student.update(notes: nil) # or whatever validation you have
      patch :update_notes, params: { id: @student.id, notes: nil }
      expect(response).to have_http_status(:success)
    end
  end

  describe '#get_all_classification' do
    it 'gets the correct classifications' do
      expect(subject.get_all_classification).to include(U1: 'U1')
      expect(subject.get_all_classification).to include(G7: 'G7')
      expect(subject.get_all_classification).to_not include(U6: 'U6')
    end
  end

  describe 'GET #quiz' do
    before do
      # Set up user and mock current_user
      @user = User.create!(email: 'teacher@gmail.com', confirmed_at: Time.now)
      allow(controller).to receive(:current_user).and_return(@user)

      @course = Course.create(course_name: 'CSCE 606', teacher: 'teacher@gmail.com', section: '600',
                              semester: 'Fall 2024')

      @students = 8.times.map do |i|
        Student.create!(
          firstname: "Student#{i}",
          lastname: "Test#{i}",
          uin: "12345#{i}",
          email: "student#{i}@example.com",
          classification: 'U2',
          major: 'CPSC',
          teacher: 'teacher@gmail.com',
          curr_practice_interval: '10',
          last_practice_at: Time.now
        )
      end

      # Loop through each student and associate with the course
      @students.each do |student|
        StudentCourse.create(student_id: student.id, course_id: @course.id)
      end
      # Stub get_due method to return students due for practice
      allow(Student).to receive(:get_due).with(@user.email).and_return(@students)

      # Create or find the QuizSession
      @quiz_session = QuizSession.create!(user: @user, courses_filter: ['CSCE 606'], semesters_filter: ['Fall 2024'],
                                          sections_filter: ['600'])
    end

    it 'creates or finds a QuizSession for the current user' do
      get :quiz
      expect(assigns(:quiz_session)).to eq(@quiz_session)
    end

    it 'filters courses based on parameters and updates @target_courses' do
      get :quiz
      expect(assigns(:target_courses)).to include(@course)
    end

    it 'filters students and selects a random due student' do
      get :quiz
      expect(assigns(:students)).to include(@students[0])
      expect(assigns(:random_student)).to be_in(assigns(:due_students))
    end

    it 'redirects to quiz filters path if no due students match filters' do
      allow(Student).to receive(:get_due).with(@user.email).and_return([])
      get :quiz
      expect(flash[:notice]).to eq('All students have been quizzed. Great job! Try again later.')
      expect(response).to redirect_to(quiz_filters_path)
    end

    it 'creates a list of 7 choices plus the random student' do
      get :quiz
      expect(assigns(:choices).size).to eq(8)
      expect(assigns(:choices)).to include(assigns(:random_student))
    end
  end

  describe '#check_answer' do
    before do
      @user = User.create(email: 'teacher@gmail.com', confirmed_at: Time.now)
      allow(controller).to receive(:current_user).and_return(@user)
      @quiz_session = QuizSession.create(user: @user, streak: 0, total_questions: 0)
      @student1 = Student.create(
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

      @student2 = Student.create(
        firstname: 'Bob',
        lastname: 'Johnson',
        uin: '987654321',
        email: 'bob@example.com',
        classification: 'U2',
        major: 'CPSC',
        teacher: 'teacher@gmail.com'
      )

      @course = Course.create(course_name: 'CSCE 606', teacher: 'teacher@gmail.com', section: '600',
                              semester: 'Fall 2024')

      StudentCourse.create(student_id: @student1.id, course_id: @course.id)
    end

    context 'when answer is correct' do
      it 'doubles the current practice interval' do
        expect do
          post :check_answer, params: {
            correct_student_id: @student1.id,
            answer: @student1.id,
            courses_text: @course.course_name,
            sections_text: @course.section,
            semesters_text: @course.semester
          }
        end.to change { @student1.reload.curr_practice_interval.to_i }.by(10)

        expect(assigns(:correctAnswer)).to be nil
        quiz_session = QuizSession.find_by(user: @user)
        expect(quiz_session.streak).to eq(1) # replace with expected streak value
        expect(quiz_session.total_questions).to eq(1)
      end
    end

    context 'when answer is incorrect' do
      it 'halves the current practice interval if it is greater than 15' do
        @student1.update(curr_practice_interval: '30')

        expect do
          post :check_answer, params: {
            correct_student_id: @student1.id,
            answer: @student2.id,
            courses: @course.course_name,
            sections: @course.section,
            semesters: @course.semester
          }
        end.to change { @student1.reload.curr_practice_interval.to_i }.by(-15)

        expect(assigns(:correctAnswer)).to be nil
      end

      it 'does not change the current practice interval if it is 15 or less' do
        @student1.update(curr_practice_interval: '10')

        expect do
          post :check_answer, params: {
            correct_student_id: @student1.id,
            answer: @student2.id,
            courses: @course.course_name,
            sections: @course.section,
            semesters: @course.semester
          }
        end.not_to(change { @student1.reload.curr_practice_interval.to_i })

        expect(assigns(:correctAnswer)).to be nil
      end
    end
  end

  describe '#index' do
    before do
      @user = User.create(email: 'teacher@gmail.com', confirmed_at: Time.now)
      allow(controller).to receive(:current_user).and_return(@user)

      @course1 = Course.create(course_name: 'CSCE 411', teacher: 'teacher@gmail.com', section: '501',
                               semester: 'Spring 2023')
      @course2 = Course.create(course_name: 'CSCE 411', teacher: 'teacher@gmail.com', section: '501',
                               semester: 'Fall 2023')

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
      @params_name = { input_name: @student1.firstname }
      @params_email = { input_email: @student2.email }
      @params_uin = { input_UIN: @student2.uin }
      @params_wrong = { input_UIN: '111111111' }
    end

    it 'displays only students enrolled in the selected course and semester' do
      get :index, params: @params
      expect(assigns(:students)).not_to include(@student2) # Bob should not be included
    end

    it 'displays only students with the correct name' do
      get :index, params: @params_name
      expect(assigns(:students)).not_to include(@student2)  # Bob should not be included
    end

    it 'displays only students with the correct email' do
      get :index, params: @params_email
      expect(assigns(:students)).not_to include(@student1)  # Alice should not be included
    end

    it 'displays only students with the correct UIN' do
      get :index, params: @params_uin
      expect(assigns(:students)).not_to include(@student1)  # Alice should not be included
    end

    it 'sets a variable when no students are found' do
      get :index, params: @params_wrong
      expect(assigns(:no_students_found)).to be true
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
    it 'redirects with a notice when student not found (HTML)' do
      get :show, params: { id: 'nonexistent_id' }, format: :html
      expect(response).to redirect_to(students_url)
      expect(flash[:notice]).to eq('Given student not found.')
    end
    it 'responds with no content when student not found (JSON)' do
      get :show, params: { id: 'nonexistent_id' }, format: :json

      expect(response).to have_http_status(:no_content)
    end
  end
end
