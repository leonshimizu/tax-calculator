class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :filing_status
      t.decimal :pay_rate
      t.decimal :retirement_rate
      t.string :position

      t.timestamps
    end
  end
end
