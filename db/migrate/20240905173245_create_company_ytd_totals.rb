# db/migrate/20240906000000_create_company_ytd_totals.rb
class CreateCompanyYtdTotals < ActiveRecord::Migration[7.1]
  def change
    create_table :company_ytd_totals do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :year, null: false
      t.decimal :gross_pay, default: "0.0"
      t.decimal :net_pay, default: "0.0"
      t.decimal :total_deductions, default: "0.0"
      t.jsonb :custom_columns_data, default: {}
      t.timestamps
    end
  end
end
