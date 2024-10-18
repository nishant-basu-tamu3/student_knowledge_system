# frozen_string_literal: true

# Student controller class
class StudentsController < ApplicationController
  # before_action :authenticate_user!
  # before_action :authenticate_by_session
  before_action :set_student, only: %i[show edit update destroy]
  before_action :require_user!

  # GET /student
  def index
    # make yearbook_style available to view
    @user = current_user
    @yearbook_style = @user.yearbook_style
    @yearbook_style = params[:yearbook_style] == 'true'

    @students = Student.search(params[:search], current_user.email)
    @emails = Set[]

    @tags = Set[]
    @courses_taken = {}
    @semesters_taken = {}
    @students&.each do |student|
      StudentsTag.where(student_id: student.id, teacher: current_user.email).each do |tag_assoc|
        tag_id = tag_assoc.tag_id
        unless (result = Tag.where(id: tag_id)).empty?
          @tags.add(result[0].tag_name)
        end
      end
    end
    @semesters = Set[]
    @sections = Set[]
    @course_names = Set[]
    @course_ids = []
    Course.where(teacher: current_user.email).each do |record|
      @semesters.add(record.semester)
      @sections.add(record.section)
      @course_names.add(record.course_name)
      @course_ids.append(record.id)
    end

    if (params[:selected_course].nil? == false) || (params[:selected_semester].nil? == false) || (params[:selected_tag].nil? == false)
      # dropdown menu selections
      @selected_tag = params[:selected_tag]
      @selected_semester = params[:selected_semester]
      @selected_course = params[:selected_course]
      # get all course id's for the selected semester + course combo
      @target_course_id = if (@selected_semester == '') && (@selected_course != '')
                            Course.where(course_name: @selected_course)
                          elsif (@selected_semester != '') && (@selected_course == '')
                            Course.where(semester: @selected_semester)
                          elsif (@selected_semester != '') && (@selected_course != '')
                            Course.where(course_name: @selected_course, semester: @selected_semester)
                          else
                            @course_ids
                          end

      @student_ids = StudentCourse.where(course_id: @target_course_id).pluck(:student_id)
      # create the filtered list of students to display
      @students = Student.where(id: @student_ids)
      if @selected_tag != ''
        selected_tag_id = Tag.where(tag_name: @selected_tag, teacher: current_user.email).pluck(:id)
        all_tag_assocs = StudentsTag.where(tag_id: selected_tag_id, teacher: current_user.email)
        @students = @students.select { |s| all_tag_assocs.any? { |assoc| s.id == assoc.student_id } }
      end
      Rails.logger.info 'Filtered students'
    else
      @target_course_id = @course_ids
    end
    @student_records_hash = {}
    @students&.each do |student|
      @student_courses = StudentCourse.where(student_id: student.id, course_id: @target_course_id)
      @student_courses.each do |student_course|
        course = Course.where(id: student_course.course_id)
        if !@student_records_hash[student.uin]
          student_entry = StudentEntries.new
          student_entry.initializeUsingStudentModel(student, course[0])
          @student_records_hash[student.uin] = student_entry
        else
          student_entry = @student_records_hash[student.uin]
          student_entry.records.append(student)
          student_entry.semester_section.add("#{course[0].semester} - #{course[0].section}")
          student_entry.course_semester.add("#{course[0].course_name} - #{course[0].semester}")
        end
      end
    end
    @students = @student_records_hash.values
  end

  # GET /students/1
  def show
    # get this student's course history
    student_courses = StudentCourse.where(student_id: @student.id)
    @course_history = Set[]
    student_courses.each do |student_course|
      course = Course.find_by(id: student_course.course_id)
      # Course history format: CSCE 999 (FALL 2019), ECEN 350 ( SPRING 2020), etc
      @course_history.add("#{course.course_name} (#{course.semester})")
    end
    # convert course history into a string
    @course_history = @course_history.to_a.join(', ')
  end

  # GET /students/1/edit
  def edit
    @all_student_course_entries = StudentCourse.where(student_id: @student.id)
    @student_course_records_hash = {}
    @all_student_course_entries.each do |student_course_db_entry|
      student_course_entry = StudentCourseEntry.new
      student_course_entry.student_record = student_course_db_entry
      @student_course_records_hash[student_course_db_entry.course_id] = student_course_entry
    end

    @all_student_course_ids = @all_student_course_entries.pluck(:course_id)
    @courses = Course.where(id: @all_student_course_ids)
    @courses.each do |course_db_entry|
      # TODO: check for nil
      student_course_entry = @student_course_records_hash[course_db_entry.id]
      student_course_entry.course_record = course_db_entry
    end

    @student_course_records = @student_course_records_hash.values
    Rails.logger.info "Collected all student courses #{@student_course_records.inspect}"
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # POST /students/
  def create
    if !Student.find_by(uin: params[:student][:uin], teacher: current_user.email)
      @student = Student.new(student_basic_params)
      tags_success = true
      unless params[:student][:tags].nil?
        tag_ids = params[:student][:tags].reject!(&:empty?)
        tag_ids = tag_ids.map! { |tag_name| Tag.where(tag_name:)[0].id }

        tag_ids.each do |element|
          unless StudentsTag.create(tag_id: element, student_id: params[:id], teacher: current_user.email)
            tags_success = false
          end
        end
      end
      if !params[:student][:create_tag].nil? && params[:student][:create_tag].strip != ''
        new_tag = Tag.find_or_create_by!(tag_name: params[:student][:create_tag], teacher: current_user.email)
        StudentsTag.create!(tag_id: new_tag.id, student_id: params[:id], teacher: current_user.email)
      end

      respond_to do |format|
        if @student.save && tags_success
          # Find or create the 'default' course
          @course = Course.find_or_create_by(course_name: 'default', teacher: current_user.email, section: 'default',
                                             semester: 'default')

          # Create the StudentCourse record
          StudentCourse.find_or_create_by(course_id: @course.id, student_id: @student.id)

          format.html { redirect_to student_url(@student), notice: 'Student was successfully created.' }
          format.json { render :show, status: :created, location: @student }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @student.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to students_url(@student), notice: 'Student with the UIN was already created.' }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    @student = Student.find(params[:id])

    current_tags = StudentsTag.where(student_id: params[:id], teacher: current_user.email)
    current_tags.delete_all
    tags_success = true
    # Remove any empty strings in the returned array
    unless params[:student][:tags].nil?
      tag_ids = params[:student][:tags].reject!(&:empty?)
      tag_ids = tag_ids.map! { |tag_name| Tag.where(tag_name:)[0].id }
      tag_ids.each do |element|
        unless StudentsTag.create(tag_id: element, student_id: params[:id], teacher: current_user.email)
          tags_success = false
        end
      end
    end

    if !params[:student][:create_tag].nil? && params[:student][:create_tag].strip != ''
      new_tag = Tag.find_or_create_by!(tag_name: params[:student][:create_tag], teacher: current_user.email)
      StudentsTag.create!(tag_id: new_tag.id, student_id: params[:id], teacher: current_user.email)
    end

    respond_to do |format|
      if @student.update(student_basic_params) && tags_success
        format.html { redirect_to student_url(@student), notice: 'Student information was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE student/id
  # Removes student and all it's courses. Or remove course of a student.
  def destroy
    @student = Student.find_by(id: params[:id])
    @student_course_records = StudentCourse.where(student_id: @student.id)
    @student_course_records.destroy_all
    @student_course_records.destroy_all
    @student.image.purge
    @student.destroy
    redirect_to action: 'index'
  end

  # GET students/1/quiz
  def quiz
    @student = Student.find_by(id: params[:id])
    @id = current_user.email
    @due_students = Student.getDue(@id)

    resp = params[:answer]
    @correct_answer = nil

    @choices = Student.where(teacher: current_user.email).where.not(id: @student.id).sample(7)
    @choices.append(@student.id)
    @choices = @choices.shuffle

    if resp.nil?
      @correct_answer = nil
    elsif resp.to_i == @student.id
      @correct_answer = true
      old_interval = @student.curr_practice_interval.to_i
      @student.update(curr_practice_interval: (old_interval * 2).to_s, last_practice_at: Time.now)

    else
      @correct_answer = false
      old_interval = @student.curr_practice_interval.to_i
      if old_interval > 15
        @student.update(curr_practice_interval: (old_interval / 2).to_s, last_practice_at: Time.now)
      else
        @student.update(last_practice_at: Time.now)
      end
    end
  end

  def getDueStudentQuiz
    return home_path unless @due_students.length.positive?

    student = @due_students.sample
    quiz_students_path(student)
  end
  helper_method :getDueStudentQuiz 

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find_by(teacher: current_user.email, id: params[:id])
    return unless @student.nil?

    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Given student not found.' }
      format.json { head :no_content }
    end
  end

  # Only allow a list of trusted parameters through.
  def student_basic_params
    params.require(:student).permit(:firstname, :lastname, :uin, :email, :classification, :major, :notes,
                                    :image, :last_practice_at, :curr_practice_interval).with_defaults(teacher: current_user.email)
  end
end
