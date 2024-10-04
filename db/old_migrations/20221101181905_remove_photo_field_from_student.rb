# frozen_string_literal: true

class RemovePhotoFieldFromStudent < ActiveRecord::Migration[7.0]
  def change
    remove_column :students, :photo
  end
end
