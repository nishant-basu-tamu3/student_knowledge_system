# frozen_string_literal: true

# Old Migrations
class DropCourses < ActiveRecord::Migration[7.0]
  def change
    drop_table(:courses, if_exists: true)
  end
end
