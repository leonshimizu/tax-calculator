class AddPayrollCalculationsToPayrollRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :payroll_records, :gross_pay, :decimal
    add_column :payroll_records, :net_pay, :decimal
    add_column :payroll_records, :withholding_tax, :decimal
    add_column :payroll_records, :social_security_tax, :decimal
    add_column :payroll_records, :medicare_tax, :decimal
    add_column :payroll_records, :retirement_payment, :decimal
  end
end
