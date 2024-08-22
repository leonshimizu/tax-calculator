class AddPayrollTypeToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :payroll_type, :string, default: 'hourly'
  end
end
