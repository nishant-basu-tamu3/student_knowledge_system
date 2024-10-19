# frozen_string_literal: true

# Class for the details of each course
class CourseEntries
  attr_accessor :records, :semesters, :sections, :course_name, :teacher

  def initialize_using_course_model(course)
    @records = Set[course]
    @semesters = Set[course.semester]
    @sections = Set[course.section]
    @course_name = course.course_name
    @teacher = course.teacher
  end
end
