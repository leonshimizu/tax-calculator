class AddRothRetirementPaymentToPayrollRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :payroll_records, :roth_retirement_payment, :decimal
  end
end
