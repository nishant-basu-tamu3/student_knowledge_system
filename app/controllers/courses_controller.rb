# frozen_string_literal: true

# Course Controller class
class CoursesController < ApplicationController
  # before_action :authenticate_user!
  # before_action :authenticate_by_session
  before_action :set_course, only: %i[show edit update destroy]
  before_action :require_user!

  # GET /courses or /courses.json
  def index
    # finds which, if any, searches were requested by looking at URL
    @courses_db_result = if request.fullpath.include?('search_course')
                           Course.search_course(params[:search_course], current_user.email)
                         elsif request.fullpath.include?('search_student')
                           Course.search_student(params[:search_student], current_user.email)
                         else
                           Course.search_semester(params[:search_semester], current_user.email)
                         end
    @courses_comb_hash = {}
    @courses_db_result.each do |c|
      if !@courses_comb_hash[c.course_name.strip]
        course_all_sections = CourseEntries.new
        course_all_sections.initializeUsingCourseModel(c)
        @courses_comb_hash[c.course_name.strip] = course_all_sections
      else
        course = @courses_comb_hash[c.course_name.strip]
        course.sections.add(c.section)
        course.semesters.add(c.semester)
        course.records.add(c)
      end
    end
    @courses = @courses_comb_hash.values
  end

  # GET /courses/1 or /courses/1.json
  def show
    # get the course id's for every past and present section of this course
    @all_course_ids = []
    Course.where(course_name: Course.where(id: params[:id])[0].course_name, teacher: current_user.email).each do |c|
      @all_course_ids.append(c.id)
    end
    # get all students currently and previously enrolled in this course
    @student_ids = StudentCourse.where(course_id: @all_course_ids).pluck(:student_id)
    @student_records = Student.where(id: @student_ids)
    # get all students tags for those currently and previously enrolled in this course
    @tags = Set[]
    @student_records&.each do |student|
      StudentsTag.where(student_id: student.id, teacher: current_user.email).each do |tag_assoc|
        tag_id = tag_assoc.tag_id
        unless (result = Tag.where(id: tag_id)).empty?
          @tags.add(result[0].tag_name)
        end
      end
    end
    # get all the current and previous semesters and sections of this course
    @semesters = Set[]
    @sections = Set[]
    Course.all.each do |record|
      if record.course_name == @course.course_name
        @semesters.add(record.semester)
        @sections.add(record.section)
      end
    end
    # if the user selects any dropdown menu filters
    if (params[:selected_semester].nil? == false) || (params[:selected_section].nil? == false) || (params[:selected_tag].nil? == false)
      # dropdown menu selections
      @selected_tag = params[:selected_tag]
      @selected_semester = params[:selected_semester]
      @selected_section = params[:selected_section]
      # get all course id's for the selected semester+section combo
      @target_course_id = if (@selected_section == '') && (@selected_semester == '')
                            Course.where(id: @all_course_ids)
                          elsif (@selected_section != '') && (@selected_semester == '')
                            Course.where(id: @all_course_ids, section: @selected_section)
                          elsif (@selected_section == '') && (@selected_semester != '')
                            Course.where(id: @all_course_ids, semester: @selected_semester)
                          else
                            Course.where(id: @all_course_ids, semester: @selected_semester,
                                         section: @selected_section)
                          end

      @student_ids = StudentCourse.where(course_id: @target_course_id.pluck(:id)).pluck(:student_id)
      # create the filtered list of students to display
      if @selected_tag != ''
        selected_tag_id = Tag.find_by(tag_name: @selected_tag).id
        all_tag_assocs = StudentsTag.where(tag_id: selected_tag_id, teacher: current_user.email)
        @student_records = @student_records.select do |record|
          all_tag_assocs.any? do |assoc|
            record.id == assoc.student_id
          end
        end
      else
        @student_records = Student.where(id: @student_ids, teacher: current_user.email)
      end
    # if the user doesnt select any dropdown menu filters, display all students
    else
      # get all the current and previous semesters and sections of this course
      @target_course_id = @all_course_ids
      @semesters = Set[]
      @sections = Set[]
      Course.all.each do |record|
        if record.course_name == @course.course_name
          @semesters.add(record.semester)
          @sections.add(record.section)
        end
      end
    end

    @student_records_hash = {}
    @student_records&.each do |student|
      student_courses = StudentCourse.where(student_id: student.id, course_id: @target_course_id)
      student_courses.each do |student_course|
        course = Course.find_by(id: student_course.course_id)
        if !@student_records_hash[student.uin]
          student_entry = StudentEntries.new
          student_entry.initializeUsingStudentModel(student, course)
          @student_records_hash[student.uin] = student_entry
        else
          student_entry = @student_records_hash[student.uin]
          student_entry.records.append(student)
          student_entry.semester_section.add("#{course.semester} - #{course.section}")
          student_entry.course_semester.add("#{course.course_name} - #{course.semester}")
        end
      end
    end
    @student_records = @student_records_hash.values
    # sort the list of students
    if params[:sortOrder] == 'Alphabetical'
      @student_records = @student_records.sort_by { |student| student.records[0].lastname }
    elsif params[:sortOrder] == 'Reverse Alphabetical'
      @student_records = @student_records.sort_by { |student| student.records[0].lastname }.reverse
    end

    Rails.logger.info "Collected info for filter #{@student_records.inspect}"
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit; end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to course_url(@course), notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to course_url(@course), notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @student_records = StudentCourse.where(course_id: params[:id])
    @student_records.destroy_all
    @course.delete

    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course and its info were successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find_by(teacher: current_user.email, id: params[:id])
    return unless @course.nil?

    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Given course not found.' }
      format.json { head :no_content }
    end
  end

  # Only allow a list of trusted parameters through.
  def course_params
    params.require(:course).permit(:course_name, :section, :semester).with_defaults(teacher: current_user.email)
  end
end
