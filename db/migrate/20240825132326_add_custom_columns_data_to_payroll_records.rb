class AddCustomColumnsDataToPayrollRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :payroll_records, :custom_columns_data, :jsonb
  end
end
