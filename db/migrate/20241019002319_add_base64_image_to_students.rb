# frozen_string_literal: true

class AddBase64ImageToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :base64_image, :text
  end
end
