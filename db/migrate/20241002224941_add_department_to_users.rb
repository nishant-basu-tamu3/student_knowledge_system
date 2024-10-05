class AddDepartmentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :department, :string
  end
end
