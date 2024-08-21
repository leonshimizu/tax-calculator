# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
PayrollRecord.destroy_all
Employee.destroy_all

# Create Employees
employees = [
  {
    first_name: "John",
    last_name: "Doe",
    filing_status: "single",
    pay_rate: 25.00,
    retirement_rate: 5.0,
    department: "back_of_house"
  },
  {
    first_name: "Jane",
    last_name: "Smith",
    filing_status: "married",
    pay_rate: 30.00,
    retirement_rate: 4.0,
    department: "front_of_house"
  },
  {
    first_name: "Alice",
    last_name: "Johnson",
    filing_status: "head_of_household",
    pay_rate: 22.50,
    retirement_rate: 6.0,
    department: "front_of_house"
  },
  {
    first_name: "Bob",
    last_name: "Brown",
    filing_status: "single",
    pay_rate: 20.00,
    retirement_rate: 3.0,
    department: "back_of_house"
  }
]

employees.each do |employee_data|
  Employee.create!(employee_data)
end

# Create Payroll Records for each employee
Employee.find_each do |employee|
  PayrollRecord.create!(
    employee_id: employee.id,
    hours_worked: 80.0,
    overtime_hours_worked: 10.0,
    reported_tips: 100.00,
    loan_payment: 50.00,
    insurance_payment: 75.00,
    date: Date.today,
    gross_pay: employee.pay_rate * 80 + (employee.pay_rate * 1.5 * 10) + 100.00,
    net_pay: nil, # This will be calculated automatically by the model
    withholding_tax: nil, # This will be calculated automatically by the model
    social_security_tax: nil, # This will be calculated automatically by the model
    medicare_tax: nil, # This will be calculated automatically by the model
    retirement_payment: nil # This will be calculated automatically by the model
  )
end

puts "Seeding complete!"
