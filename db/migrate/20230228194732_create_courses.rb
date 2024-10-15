# frozen_string_literal: true

# Migration
class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.string :semester, null: false
      t.string :teacher, null: false
      t.integer :section, null: false
      t.string :course_name, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
