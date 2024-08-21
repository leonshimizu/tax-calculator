class RenamePositionToDepartment < ActiveRecord::Migration[7.1]
  def change
    rename_column :employees, :position, :department
  end
end
