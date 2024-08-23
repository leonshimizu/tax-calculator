class AddRothRetirementToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :roth_retirement_rate, :decimal
  end
end
