# frozen_string_literal: true

# Migration
class CreateStudentsTags < ActiveRecord::Migration[6.1]
  def change
    create_table :students_tags do |t|
      # t.references :student, foreign_key: true
      # t.references :tag, foreign_key: true
      t.integer 'student_id'
      t.integer 'tag_id'
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :teacher
    end

    # add_foreign_key :students_tags, :users, column: :teacher, primary_key: "email"
  end
end
