# frozen_string_literal: true

# Old Migrations
class RemoveUserIdColumnInStudentsTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :students_tags, :user_id
  end
end
