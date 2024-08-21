class SplitNameIntoFirstAndLastName < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :first_name, :string
    add_column :employees, :last_name, :string

    Employee.reset_column_information

    Employee.find_each do |employee|
      split_names = employee.name.split(' ', 2)
      employee.update_columns(first_name: split_names.first, last_name: split_names.last)
    end

    remove_column :employees, :name
  end
end
