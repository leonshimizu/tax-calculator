class AddTotalAdditionsToPayrollRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :payroll_records, :total_additions, :decimal
  end
end
