# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  before do
    email = 'student@gmail.com'
    @user = User.create(email:, confirmed_at: Time.now)

    allow(controller).to receive(:current_user).and_return(@user)

    @course1 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                             semester: 'Fall 2022')
    @course2 = Course.create(course_name: 'CSCE 411', teacher: 'student@gmail.com', section: '501',
                             semester: 'Spring 2023')
    @course3 = Course.create(course_name: 'CSCE 412', teacher: 'student@gmail.com', section: '501',
                             semester: 'Spring 2023')

    @student1 = Student.create(firstname: 'Zebulun', lastname: 'Oliphant', uin: '734826482', email: 'zeb@tamu.edu',
                               classification: 'U2', major: 'CPSC', teacher: 'student@gmail.com')
    @student2 = Student.create(firstname: 'Batmo', lastname: 'Biel', uin: '274027450', email: 'speedwagon@tamu.edu',
                               classification: 'U1', major: 'CPSC', teacher: 'student@gmail.com')
    @student3 = Student.create(firstname: 'Ima', lastname: 'Hogg', uin: '926409274', email: 'piglet@tamu.edu',
                               classification: 'U1', major: 'CPSC', teacher: 'student@gmail.com')
    @student4 = Student.create(firstname: 'Joe', lastname: 'Mama', uin: '720401677', email: 'howisjoe@tamu.edu',
                               classification: 'U1', major: 'CPSC', teacher: 'student@gmail.com')
    @student5 = Student.create(firstname: 'Sheev', lastname: 'Palpatine', uin: '983650274', email: 'senate@tamu.edu',
                               classification: 'U1', major: 'CPSC', teacher: 'student@gmail.com')

    StudentCourse.create(
      course_id: Course.find_by(course_name: 'CSCE 411', semester: 'Fall 2022',
                                section: '501').id, student_id: Student.find_by(uin: '734826482').id, final_grade: '100'
    )
    StudentCourse.create(
      course_id: Course.find_by(course_name: 'CSCE 411', semester: 'Fall 2022',
                                section: '501').id, student_id: Student.find_by(uin: '926409274').id, final_grade: ''
    )
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

    @tag1 = Tag.create(tag_name: 'is cool', created_at: Time.now, updated_at: Time.now, teacher: @user.email)
    StudentsTag.create(student_id: @student1.id, tag_id: @tag1.id, created_at: Time.now, updated_at: Time.now,
                       teacher: @user.email)
  end

  describe '#index' do
    context 'when searching for a course' do
      before do
        get :index, params: { search_course: 'CSCE 411' }
      end

      it 'assigns @courses with the matching course and its details' do
        # expect(controller.current_user).to eq(@user)
        # puts "accessed controller with session"
        # puts "current_user: #{current_user.inspect}"
        # puts "@user: #{@user.inspect}"

        #   puts "course1: #{@course1.inspect}"
        #   puts "course2: #{@course2.inspect}"
        expect(assigns(:courses_db_result)).to match_array([@course1, @course2])
      end
    end

    context 'when searching for a student' do
      before do
        get :index, params: { search_student: 'Zebulun' }
      end

      it 'assigns @courses with the courses the student is enrolled in and their details' do
        expect(assigns(:courses_db_result)).to match_array([@course1, @course3])
      end
    end

    context 'when searching for a semester' do
      before do
        get :index, params: { search_semester: 'Spring 2023' }
      end

      it 'assigns @courses with the courses in the semester and their details' do
        expect(assigns(:courses_db_result)).to match_array([@course2, @course3])
      end
    end

    context 'no results exist for search semester' do
      before do
        get :index, params: { search_student: '' }
      end

      it 'assigns @courses with the courses in the semester and their details' do
        expect(assigns(:courses_db_result).length).to eq(0)
      end
    end

    context 'no results exist for search student' do
      before do
        get :index, params: { search_course: '' }
      end

      it 'assigns @courses with the courses the student is enrolled in and their details' do
        expect(assigns(:courses_db_result).length).to eq(3)
      end
    end

    context 'no results exist for search semester' do
      before do
        get :index, params: { search_semester: '' }
      end

      it 'assigns @courses with the matching course and its details' do
        expect(assigns(:courses_db_result).length).to eq(0)
      end
    end
  end

  describe 'GET #show' do
    it 'assigns all_course_ids, student_ids, tags, semesters, sections and student_records' do
      get :show, params: { id: @course1.id }
      expect(assigns(:all_course_ids)).to include(@course1.id)
      expect(assigns(:student_ids)).to include(@student1.id)
      expect(assigns(:tags)).to be_an_instance_of(Set)
      expect(assigns(:semesters)).to be_an_instance_of(Set)
      expect(assigns(:sections)).to be_an_instance_of(Set)
      expect(assigns(:student_records)).to be_an_instance_of(Array)
    end

    it 'assigns filtered student_records based on dropdown menu selections' do
      get :show, params: { id: @course1.id, selected_tag: 'is cool' }
      expect(assigns(:student_ids).count).to eq(0)
    end

    it 'sorts the list of students based on sort order' do
      get :show, params: { id: @course1.id, sortOrder: 'Alphabetical' }
      expect(assigns(:student_records).first.records.first.lastname).to eq('Biel')

      get :show, params: { id: @course1.id, sortOrder: 'Reverse Alphabetical' }
      expect(assigns(:student_records).first.records.first.lastname).to eq('Oliphant')
    end

    it 'initializes new student entry when student is not in @student_records_hash' do
      get :show, params: { id: @course1.id }
      
      # Check if the student is initialized correctly
      student_entry = assigns(:student_records_hash)[@student2.uin]
      expect(student_entry).to be_present
    end
  
    it 'appends student records when student already exists in @student_records_hash' do
      # Create a situation where the student already has an entry
      @student_records_hash = {}
      existing_student = @student1 # Assume @student1 is already in the hash
      existing_student_courses = StudentCourse.where(student_id: existing_student.id, course_id: @course1.id)
  
      existing_student_courses.each do |student_course|
        course = Course.find_by(id: student_course.course_id)
        student_entry = @student_records_hash[existing_student.uin] || StudentEntries.new
        student_entry.initializeUsingStudentModel(existing_student, course)
        @student_records_hash[existing_student.uin] = student_entry
      end
  
      # Now get the show action again to simulate adding the existing student
      get :show, params: { id: @course1.id }
      
      # Check if the existing student entry has been updated
      student_entry = assigns(:student_records_hash)[existing_student.uin]
      expect(student_entry.records).to include(existing_student)
      expect(student_entry.semester_section).to include("#{@course1.semester} - #{@course1.section}")
      expect(student_entry.course_semester).to include("#{@course1.course_name} - #{@course1.semester}")
    end
  
    it 'sorts the list of students based on sort order' do
      get :show, params: { id: @course1.id, sortOrder: 'Alphabetical' }
      expect(assigns(:student_records).first.records.first.lastname).to eq('Biel')
  
      get :show, params: { id: @course1.id, sortOrder: 'Reverse Alphabetical' }
      expect(assigns(:student_records).first.records.first.lastname).to eq('Oliphant')
    end
  end

  describe 'GET #new' do
    it 'assigns a new Course to @course' do
      get :new
      expect(assigns(:course)).to be_a_new(Course)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get :edit, params: { id: @course1.id }
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new course' do
        expect do
          post :create,
               params: { course: { course_name: 'CSCE 421', teacher: 'student@gmail.com', section: '501',
                                   semester: 'Fall 2022' } }
        end.to change(Course, :count).by(1)
      end

      it 'redirects to the new course' do
        post :create,
             params: { course: { course_name: 'CSCE 421', teacher: 'student@gmail.com', section: '501',
                                 semester: 'Fall 2022' } }
        expect(response).to redirect_to(course_path(assigns[:course]))
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        it 'updates the requested course' do
          patch :update, params: { id: @course1.id, course: { course_name: 'CSCE 431' } }
          @course1.reload
          expect(@course1.course_name).to eq('CSCE 431')
        end

        it 'redirects to the updated course' do
          patch :update, params: { id: @course2.id, course: { course_name: 'CSCE 431' } }
          expect(response).to redirect_to(course_path(assigns[:course]))
        end
      end

      # it "renders the edit template" do
      # patch :update, params: { id: @course3.id, course: { course_name: "CSCE 431" } }
      # expect(response).to render_template :edit
      # end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the course' do
      expect do
        delete :destroy, params: { id: @course1.id }
      end.to change(Course, :count).by(-1)
    end

    it 'deletes all student_course records associated with the course' do
      expect do
        delete :destroy, params: { id: @course1.id }
      end.to change(StudentCourse, :count).by(-2)
    end

    it 'redirects to courses_url' do
      delete :destroy, params: { id: @course1.id }
      expect(response).to redirect_to(courses_url)
    end

    it 'displays a success notice' do
      delete :destroy, params: { id: @course1.id }
      expect(flash[:notice]).to eq('Course and its info were successfully deleted.')
    end
  end

  describe 'GET #set_course' do
    context 'when the course is found' do
      before do
        get :show, params: { id: @course1.id }
      end

      it 'assigns the course to @course' do
        expect(assigns(:course)).to eq(@course1)
      end
    end

    context 'when the course is not found' do
      before do
        get :show, params: { id: 'non-existent-id' } # Using a non-existent ID
      end

      it 'sets @course to nil' do
        expect(assigns(:course)).to be_nil
      end

      it 'redirects to courses_url' do
        expect(response).to redirect_to(courses_url)
      end

      it 'sets a flash notice message' do
        expect(flash[:notice]).to eq('Given course not found.')
      end

      it 'responds with no content for JSON requests' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        get :show, params: { id: 'non-existent-id' } # Same non-existent ID for JSON request
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'GET #set_course' do
    context 'when the course is found' do
      before do
        get :show, params: { id: @course1.id }
      end

      it 'assigns the course to @course' do
        expect(assigns(:course)).to eq(@course1)
      end
    end

    context 'when the course is not found' do
      before do
        get :show, params: { id: 'non-existent-id' } # Using a non-existent ID
      end

      it 'sets @course to nil' do
        expect(assigns(:course)).to be_nil
      end

      it 'redirects to courses_url' do
        expect(response).to redirect_to(courses_url)
      end

      it 'sets a flash notice message' do
        expect(flash[:notice]).to eq('Given course not found.')
      end

      it 'responds with no content for JSON requests' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        get :show, params: { id: 'non-existent-id' } # Same non-existent ID for JSON request
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
