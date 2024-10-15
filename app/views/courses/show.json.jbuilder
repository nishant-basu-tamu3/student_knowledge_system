# frozen_string_literal: true

json.partial! 'courses/course', course: @course
json.array! @student_records, partial: 'students/student', as: :student
