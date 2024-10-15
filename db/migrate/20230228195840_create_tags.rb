# frozen_string_literal: true

# Migration
class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :tag_name, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :teacher
    end

    # add_foreign_key :tags, :users, column: :teacher, primary_key: "email"
  end
end
