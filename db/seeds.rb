# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample employees
employees = Employee.create([
  { name: "Alice Johnson", filing_status: "single", pay_rate: 25.0, retirement_rate: 5, position: "front_of_house" },
  { name: "Bob Smith", filing_status: "married", pay_rate: 30.0, retirement_rate: 7, position: "back_of_house" }
])

# For each employee, create payroll records
employees.each do |employee|
  PayrollRecord.create([
    {
      employee_id: employee.id,
      hours_worked: 40,
      overtime_hours_worked: 5,
      reported_tips: 120.50,
      loan_payment: 50,
      insurance_payment: 100,
      date: Date.today - 15,
      gross_pay: 1400, # Assume gross pay needs to be calculated or set here for the example
      net_pay: 1200, # Same assumption as gross pay
      withholding_tax: 200,
      social_security_tax: 86.80, # 6.2% of gross for SS tax, just as an example
      medicare_tax: 20.30, # 1.45% of gross for Medicare tax
      retirement_payment: 70 # 5% of gross pay for retirement
    },
    {
      employee_id: employee.id,
      hours_worked: 42,
      overtime_hours_worked: 3,
      reported_tips: 100,
      loan_payment: 50,
      insurance_payment: 100,
      date: Date.today - 7,
      gross_pay: 1450,
      net_pay: 1250,
      withholding_tax: 210,
      social_security_tax: 89.90,
      medicare_tax: 21.05,
      retirement_payment: 72.50
    }
  ])
end

puts "Seeds created successfully!"

