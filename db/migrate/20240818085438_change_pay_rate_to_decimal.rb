class ChangePayRateToDecimal < ActiveRecord::Migration[7.1]
  def change
    change_column :employees, :pay_rate, :decimal, precision: 10, scale: 2
  end
end
