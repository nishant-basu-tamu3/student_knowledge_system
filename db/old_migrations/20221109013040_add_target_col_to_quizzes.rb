# frozen_string_literal: true

# Old Migrations
class AddTargetColToQuizzes < ActiveRecord::Migration[7.0]
  def change
    add_column :quizzes, :targeted, :boolean, default: false
  end
end
