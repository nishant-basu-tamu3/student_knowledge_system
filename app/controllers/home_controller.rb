# frozen_string_literal: true

# Home Controller class
class HomeController < ApplicationController
  before_action :require_user!
  # before_action :authenticate_user!
  # before_action :authenticate_by_session

  def index
    @current_user = current_user
    @id = current_user.email
    @due_students = Student.getDue(@id)
  end

  def stripYear(var)
    tmp = var.strip
    idx = tmp.rindex(' ')
    unless idx.nil?
      idx += 1
      tmp = tmp[idx..].strip
    end
    tmp
  end

  def getYears
    sems = Course.where(teacher: @id)
    uniq_sems = Set.new
    sems.each do |s|
      year = stripYear(s.semester)
      uniq_sems << year
    end
    uniq_sems.length
  end
  helper_method :getYears

  def get_num_due
    @due_students.length
  end
  helper_method :get_num_due

  def get_due_student_quiz
    return home_path unless @due_students.length.positive?

    student = @due_students.sample
    quiz_students_path(student)
  end
  helper_method :get_due_student_quiz
end
