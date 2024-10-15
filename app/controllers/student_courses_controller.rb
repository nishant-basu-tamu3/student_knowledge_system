# frozen_string_literal: true

# Student course controller class
class StudentCoursesController < ApplicationController
  before_action :require_user!

  def update
    @student_course = StudentCourse.find_by(id: params[:id])
    @student = Student.find(@student_course.student_id)
    respond_to do |format|
      if @student_course.update(final_grade: params[:student_course]['final_grade'])
        format.html do
          redirect_to student_url(@student), notice: 'Student information was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
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
end
