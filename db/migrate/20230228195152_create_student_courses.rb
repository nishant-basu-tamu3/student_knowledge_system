# frozen_string_literal: true

# Migration
class CreateStudentCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :student_courses do |t|
      t.integer 'student_id'
      t.integer 'course_id'
      t.string 'final_grade', default: ''
      # t.datetime "created_at", null: false
      # t.datetime "updated_at", null: false

      t.timestamps
    end

    # add_foreign_key :student_courses, :students
    # add_foreign_key :student_courses, :courses
  end
end
