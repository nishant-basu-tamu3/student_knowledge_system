# frozen_string_literal: true

# Old Migrations
class RemoveTagsFromStudents < ActiveRecord::Migration[7.0]
  def change
    remove_column :students, :tags
  end
end
