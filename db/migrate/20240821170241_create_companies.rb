class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_reference :employees, :company, foreign_key: true
  end
end
