# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_18_083954) do
  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.string "filing_status"
    t.decimal "pay_rate"
    t.decimal "retirement_rate"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payroll_records", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.decimal "hours_worked"
    t.decimal "overtime_hours_worked"
    t.decimal "reported_tips"
    t.decimal "loan_payment"
    t.decimal "insurance_payment"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "gross_pay"
    t.decimal "net_pay"
    t.decimal "withholding_tax"
    t.decimal "social_security_tax"
    t.decimal "medicare_tax"
    t.decimal "retirement_payment"
    t.index ["employee_id"], name: "index_payroll_records_on_employee_id"
  end

  add_foreign_key "payroll_records", "employees"
end
