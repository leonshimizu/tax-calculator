class UpdateBonusAndPayrollRecords < ActiveRecord::Migration[7.1]
  def change
    change_column :payroll_records, :bonus, :decimal, precision: 12, scale: 3, default: 0.0
    change_column :payroll_records, :total_deductions, :decimal, precision: 12, scale: 3, default: 0.0
  end
end
