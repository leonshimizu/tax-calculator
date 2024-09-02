class AddDepartmentToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_reference :employees, :department, foreign_key: true
    remove_column :employees, :department, :string
  end
end
