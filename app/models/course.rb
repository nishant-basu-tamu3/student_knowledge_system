# frozen_string_literal: true

# Course Model Class
class Course < ApplicationRecord
  def self.search_course(search, teacher)
    if search
      search_type = Course.where(course_name: search, teacher:).all
      if search_type
        where(id: search_type)
      elsif search_type.empty?
        @courses_db_result = Course.where(teacher:)
      else
        @courses_db_result = Course.where(id: 0)
      end
    else
      @courses_db_result = Course.where(teacher:)
    end
  end

  def self.search_semester(search, teacher)
    if search
      search_type = Course.where(semester: search, teacher:).all
      if search_type
        where(id: search_type)
      elsif search_type.empty?
        @courses_db_result = Course.where(teacher:)
      else
        @courses_db_result = Course.where(id: 0)
      end
    else
      @courses_db_result = Course.where(teacher:)
    end
  end

  def self.search_student(search, teacher)
    if search
      student = if search.include?(' ')
                  Student.where(firstname: search.split(' ')[0], lastname: search.split(' ')[1]).all
                else
                  Student.where(firstname: search).all + Student.where(lastname: search).all
                end
      enrollment = []
      student.each do |stud|
        puts stud.firstname
        enrollment += StudentCourse.where(student_id: stud.id).all
        puts enrollment[0].id
      end
      search_type = []
      enrollment.each do |enroll|
        search_type += Course.where(id: enroll.course_id, teacher:).all
        puts search_type[0]
      end
      if search_type
        where(id: search_type)
      elsif search_type.empty?
        @courses_db_result = Course.where(teacher:)
      else
        @courses_db_result = Course.where(id: 0)
      end
    else
      @courses_db_result = Course.where(teacher:)
    end
  end
end
