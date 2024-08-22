class AddBonusAndTotalDeductionsToPayrollRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :payroll_records, :bonus, :decimal
    add_column :payroll_records, :total_deductions, :decimal
  end
end
