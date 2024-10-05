# frozen_string_literal: true

# Old Migrations
class DropUsersForeignKey < ActiveRecord::Migration[7.0]
  def change
    # remove_foreign_key :courses, column: :teacher
  end
end
