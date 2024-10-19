# frozen_string_literal: true

require 'test_helper'

class StudentCoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:userOne)
    @student = students(:studentOne)
    @student_one_course_one = student_courses(:student_one_course_one)
  end

  test 'should destroy student of a course' do
    before_student_count = Student.count
    before_student_course_count = StudentCourse.count
    delete student_course_path(@student_one_course_one.id)
    after_student_count = Student.count
    after_student_course_count = StudentCourse.count
    assert_equal before_student_count, after_student_count
    assert_equal before_student_course_count - 1, after_student_course_count
    assert_redirected_to student_url(@student)
  end

  test 'should update grade of student in a course' do
    patch student_course_path(@student_one_course_one), params: { student_course: { final_grade: 'A' } }
    assert_redirected_to student_url(@student)
  end
end
