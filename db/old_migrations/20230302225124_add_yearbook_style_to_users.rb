# frozen_string_literal: true

# Old Migrations
class AddYearbookStyleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :yearbook_style, :boolean
  end
end
