# frozen_string_literal: true

# Old Migrations
class AddProfColToQuizzes < ActiveRecord::Migration[7.0]
  def change
    add_column :quizzes, :teacher, :string
  end
end
