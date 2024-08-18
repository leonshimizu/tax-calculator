class CreatePayrollRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :payroll_records do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :hours_worked
      t.decimal :overtime_hours_worked
      t.decimal :reported_tips
      t.decimal :loan_payment
      t.decimal :insurance_payment
      t.date :date

      t.timestamps
    end
  end
end
