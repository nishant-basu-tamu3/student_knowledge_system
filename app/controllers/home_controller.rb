# frozen_string_literal: true

# Home Controller class
class HomeController < ApplicationController
  before_action :require_user!
  # before_action :authenticate_user!
  # before_action :authenticate_by_session

  def index
    @current_user = current_user
    @id = current_user.email
    @due_students = Student.get_due(@id)
  end

  def strip_year(var)
    tmp = var.strip
    idx = tmp.rindex(' ')
    unless idx.nil?
      idx += 1
      tmp = tmp[idx..].strip
    end
    tmp
  end

  def years
    sems = Course.where(teacher: @id)
    uniq_sems = Set.new
    sems.each do |s|
      year = strip_year(s.semester)
      uniq_sems << year
    end
    uniq_sems.length
  end
  helper_method :years

  def num_due
    @due_students.length
  end
  helper_method :num_due

  def reset_quiz_cohort
    ActiveRecord::Base.transaction do
      Student.where(teacher: current_user.email).update_all(last_practice_at: 1.minute.ago, curr_practice_interval: '1')
      quiz_session = QuizSession.find_by(user: current_user)
      quiz_session&.update(streak: 0, total_questions: 0, correct_answers: 0)
    end

    @due_students = Student.get_due(current_user.email)

    flash[:notice] = 'Quiz cohort has been reset. You can now practice with all students.'
    redirect_to home_path
  end

  def students_status
    total_students = Student.where(teacher: current_user.email).count
    if total_students.zero?
      :no_students
    elsif num_due.zero?
      :all_quizzed
    else
      :students_due
    end
  end
  helper_method :students_status

  def due_student_quiz
    return home_path unless @due_students.length.positive?

    student = @due_students.sample
    quiz_students_path(student)
  end
  helper_method :due_student_quiz
end
