# frozen_string_literal: true

# Old Migrations
class RemoveQuizAndQroster < ActiveRecord::Migration[7.0]
  def change
    drop_table(:quizzes, if_exists: true)
    drop_table(:qrosters, if_exists: true)
  end
end
