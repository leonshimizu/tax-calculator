# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Clear existing data
PayrollRecord.destroy_all
Employee.destroy_all
Company.destroy_all

# db/seeds.rb

# Create companies
company1 = Company.create!(name: "Tech Innovators Inc.")
company2 = Company.create!(name: "Creative Solutions LLC")

# Create employees for company1
employee1 = company1.employees.create!(
  first_name: "John",
  last_name: "Doe",
  payroll_type: "hourly",
  department: "front_of_house",
  pay_rate: 20.00,
  retirement_rate: 5.0,
  filing_status: "single"
)

employee2 = company1.employees.create!(
  first_name: "Jane",
  last_name: "Smith",
  payroll_type: "salary",
  department: "salary",
  gross_pay: 5000.00,
  retirement_rate: 3.0,
  filing_status: "married"
)

# Create employees for company2
employee3 = company2.employees.create!(
  first_name: "Emily",
  last_name: "Johnson",
  payroll_type: "hourly",
  department: "back_of_house",
  pay_rate: 18.50,
  retirement_rate: 4.0,
  filing_status: "head_of_household"
)

employee4 = company2.employees.create!(
  first_name: "Michael",
  last_name: "Brown",
  payroll_type: "salary",
  department: "salary",
  gross_pay: 6000.00,
  retirement_rate: 6.0,
  filing_status: "single"
)

# Create payroll records for company1 hourly employee
employee1.payroll_records.create!(
  date: "2024-08-15",
  hours_worked: 80,
  overtime_hours_worked: 5,
  reported_tips: 200.00,
  loan_payment: 50.00,
  insurance_payment: 100.00
)

# Create payroll records for company1 salary employee
employee2.payroll_records.create!(
  date: "2024-08-15",
  gross_pay: 5000.00,
  bonus: 500.00,
  loan_payment: 150.00,
  insurance_payment: 200.00
)

# Create payroll records for company2 hourly employee
employee3.payroll_records.create!(
  date: "2024-08-15",
  hours_worked: 75,
  overtime_hours_worked: 8,
  reported_tips: 150.00,
  loan_payment: 30.00,
  insurance_payment: 80.00
)

# Create payroll records for company2 salary employee
employee4.payroll_records.create!(
  date: "2024-08-15",
  gross_pay: 6000.00,
  bonus: 600.00,
  loan_payment: 100.00,
  insurance_payment: 150.00
)

puts "Seeding completed successfully!"
