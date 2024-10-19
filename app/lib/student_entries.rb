# frozen_string_literal: true

class StudentEntries
  attr_accessor :records, :semester_section, :course_semester

  def initialize_using_student_model(student, course)
    @records = [student]
    @semester_section = Set["#{course.semester} - #{course.section}"]
    @course_semester = Set["#{course.course_name} - #{course.semester}"]
  end
end
