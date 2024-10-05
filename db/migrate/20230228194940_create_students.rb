# frozen_string_literal: true

# Migration
class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :uin, null: false
      t.string :email, null: false
      t.string :classification, null: false
      t.string :major, null: false
      t.text :notes
      t.string :teacher, null: false
      t.datetime :last_practice_at
      t.string :curr_practice_interval

      t.timestamps
    end

    # add_foreign_key :students, :users, column: :teacher, primary_key: :email
  end
end
