# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  let!(:teacher) { User.create(email: 'teacher@example.com') }
  let!(:student1) { Student.create(firstname: 'John', lastname: 'Doe', uin: '12345', email: 'john@example.com', classification: 'Freshman', major: 'Math', teacher: teacher.email) }
  let!(:student2) { Student.create(firstname: 'Jane', lastname: 'Smith', uin: '67890', email: 'jane@example.com', classification: 'Sophomore', major: 'Science', teacher: teacher.email) }
  
  let!(:course1) { Course.create(semester: 'Fall 2024', teacher: teacher.email, section: 1, course_name: 'Math 101') }
  let!(:course2) { Course.create(semester: 'Fall 2024', teacher: teacher.email, section: 2, course_name: 'Science 101') }
  
  let!(:student_course1) { StudentCourse.create(student_id: student1.id, course_id: course1.id) }
  let!(:student_course2) { StudentCourse.create(student_id: student2.id, course_id: course2.id) }

  describe '.search_student' do
    context 'when a student name is provided' do
      it 'returns all courses for the specified student' do
        result = Course.search_student('John Doe', teacher.email)
        expect(result).to include(course1)
        expect(result).not_to include(course2)
      end

      it 'returns courses when only firstname is provided' do
        result = Course.search_student('Jane', teacher.email)
        expect(result).to include(course2)
      end

      it 'returns courses when only lastname is provided' do
        result = Course.search_student('Smith', teacher.email)
        expect(result).to include(course2)
      end

      it 'returns an empty array if no courses match' do
        result = Course.search_student('Nonexistent Student', teacher.email)
        expect(result).to be_empty
      end
    end

    context 'when no student name is provided' do
      it 'returns all courses for the teacher' do
        result = Course.search_student(nil, teacher.email)
        expect(result).to include(course1, course2)
      end
    end
  end

  describe '.search_course' do
    context 'when a course name is provided' do
      it 'returns the specific course' do
        result = Course.search_course('Math 101', teacher.email)
        expect(result).to include(course1)
        expect(result).not_to include(course2)
      end

      it 'returns all courses if the course does not exist' do
        result = Course.search_course('Nonexistent Course', teacher.email)
        expect(result).to include(course1, course2)
      end
    end

    context 'when no course name is provided' do
      it 'returns all courses for the teacher' do
        result = Course.search_course(nil, teacher.email)
        expect(result).to include(course1, course2)
      end
    end
  end

  describe '.search_semester' do
    context 'when a semester is provided' do
      it 'returns the courses for that semester' do
        result = Course.search_semester('Fall 2024', teacher.email)
        expect(result).to include(course1, course2)
      end

      it 'returns an empty array if no courses match' do
        result = Course.search_semester('Spring 2025', teacher.email)
        expect(result).to be_empty
      end
    end

    context 'when no semester is provided' do
      it 'returns all courses for the teacher' do
        result = Course.search_semester(nil, teacher.email)
        expect(result).to include(course1, course2)
      end
    end
  end
end
