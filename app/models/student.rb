# frozen_string_literal: true

# Student Model Class
class Student < ApplicationRecord

  # validates :firstname, :lastname, :email, :major, :classification, :uin, :create_tag, presence: true
  # validate :check_all_fields

  # def check_all_fields
  #   if [firstname, lastname, email, major, classification, uin, create_tag].any?(&:blank?)
  #     errors.add(:base, "Fill all fields")
  #   end
  # end

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [500, 500]
  end

  def self.search(search, teacher)
    if search
      search_type = Student.find_by(email: search, teacher:)
      if search_type
        where(id: search_type)
      elsif search.empty?
        # return no results
        @students = Student.where(teacher:)
      else
        @students = Student.where(id: 0)
      end
    else
      @students = Student.where(teacher:)
    end
  end

  # get the number of students due for quizzing
  def self.getDue(teacher)
    students = Student.where(teacher:)
    dueStudents = []
    students.each do |student|
      dueStudents += [student] if (student.last_practice_at + student.curr_practice_interval.to_i.minutes) < Time.now
    end
    dueStudents
  end
end
