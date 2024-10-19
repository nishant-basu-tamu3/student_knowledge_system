# frozen_string_literal: true

# Student course controller class
class StudentCoursesController < ApplicationController
  before_action :require_user!

  def update
    @student_course = StudentCourse.find_by(id: params[:id])
    @student = Student.find(@student_course.student_id)
    if @student_course&.update(final_grade: params[:student_course]['final_grade'])
      respond_to_redirect(student_url(@student), 'Student information was successfully updated.')
    else
      respond_to_failure(@student.errors)
    end
  end

  def destroy
    @student_course = StudentCourse.find_by(id: params[:id])
    @student = Student.find(@student_course.student_id)
    @student_course.delete
    respond_to do |format|
      format.html { redirect_to student_url(@student), notice: 'Given student in a course is deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def respond_to_redirect(url, notice)
    respond_to do |format|
      format.html { redirect_to url, notice: }
      format.json { render :show, status: :ok, location: @student }
    end
  end

  def respond_to_failure(errors)
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: errors, status: :unprocessable_entity }
    end
  end
end
