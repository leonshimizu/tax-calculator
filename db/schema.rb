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

ActiveRecord::Schema[7.1].define(version: 2024_08_29_192026) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_columns", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.string "data_type", default: "decimal"
    t.boolean "include_in_payroll", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deduction", default: true, null: false
    t.index ["company_id"], name: "index_custom_columns_on_company_id"
  end

  create_table "employees", force: :cascade do |t|
    t.string "filing_status"
    t.decimal "pay_rate", precision: 10, scale: 2
    t.decimal "retirement_rate"
    t.string "department"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "company_id"
    t.string "payroll_type", default: "hourly"
    t.decimal "roth_retirement_rate"
    t.index ["company_id"], name: "index_employees_on_company_id"
  end

  create_table "payroll_records", force: :cascade do |t|
    t.bigint "employee_id", null: false
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
    t.decimal "bonus", precision: 12, scale: 3, default: "0.0"
    t.decimal "total_deductions", precision: 12, scale: 3, default: "0.0"
    t.decimal "roth_retirement_payment"
    t.jsonb "custom_columns_data"
    t.decimal "total_additions"
    t.index ["employee_id"], name: "index_payroll_records_on_employee_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.boolean "admin", default: false
  end

  add_foreign_key "custom_columns", "companies"
  add_foreign_key "employees", "companies"
  add_foreign_key "payroll_records", "employees"
end
