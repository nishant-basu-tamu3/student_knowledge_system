# frozen_string_literal: true

# Old Migrations
class RenameClassIdToCourseIdInCourses < ActiveRecord::Migration[7.0]
  def change
    rename_column :students, :class_id, :course_id
  end
end
