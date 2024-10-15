# frozen_string_literal: true

# Migration
class AddForeignKeys < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
    add_foreign_key :student_courses, :courses
    add_foreign_key :student_courses, :students
    add_foreign_key 'students', 'users', column: 'teacher', primary_key: 'email'
    add_foreign_key 'students_tags', 'users', column: 'teacher', primary_key: 'email'
    add_foreign_key 'tags', 'users', column: 'teacher', primary_key: 'email'
  end
end
