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

# Create Companies
company1 = Company.create!(name: 'Tech Corp')
company2 = Company.create!(name: 'Health Solutions')

# Create Employees for Company 1
employee1 = company1.employees.create!(
  first_name: 'John',
  last_name: 'Doe',
  filing_status: 'single',
  pay_rate: 25.00,
  retirement_rate: 5.0,
  department: 'front_of_house'
)

employee2 = company1.employees.create!(
  first_name: 'Jane',
  last_name: 'Smith',
  filing_status: 'married',
  pay_rate: 30.00,
  retirement_rate: 6.0,
  department: 'back_of_house'
)

# Create Employees for Company 2
employee3 = company2.employees.create!(
  first_name: 'Emily',
  last_name: 'Jones',
  filing_status: 'head_of_household',
  pay_rate: 28.00,
  retirement_rate: 4.5,
  department: 'front_of_house'
)

employee4 = company2.employees.create!(
  first_name: 'Michael',
  last_name: 'Brown',
  filing_status: 'single',
  pay_rate: 32.00,
  retirement_rate: 7.0,
  department: 'back_of_house'
)

# Create Payroll Records for Employees in Company 1
employee1.payroll_records.create!(
  date: Date.today,
  hours_worked: 40,
  overtime_hours_worked: 5,
  reported_tips: 100.00,
  loan_payment: 50.00,
  insurance_payment: 20.00,
  gross_pay: 1100.00,
  net_pay: 900.00,
  withholding_tax: 150.00,
  social_security_tax: 68.20,
  medicare_tax: 15.95,
  retirement_payment: 55.00
)

employee2.payroll_records.create!(
  date: Date.today,
  hours_worked: 38,
  overtime_hours_worked: 2,
  reported_tips: 120.00,
  loan_payment: 60.00,
  insurance_payment: 30.00,
  gross_pay: 1150.00,
  net_pay: 950.00,
  withholding_tax: 160.00,
  social_security_tax: 71.30,
  medicare_tax: 16.68,
  retirement_payment: 69.00
)

# Create Payroll Records for Employees in Company 2
employee3.payroll_records.create!(
  date: Date.today,
  hours_worked: 42,
  overtime_hours_worked: 3,
  reported_tips: 90.00,
  loan_payment: 40.00,
  insurance_payment: 25.00,
  gross_pay: 1200.00,
  net_pay: 1000.00,
  withholding_tax: 170.00,
  social_security_tax: 74.40,
  medicare_tax: 17.40,
  retirement_payment: 54.00
)

employee4.payroll_records.create!(
  date: Date.today,
  hours_worked: 45,
  overtime_hours_worked: 4,
  reported_tips: 110.00,
  loan_payment: 70.00,
  insurance_payment: 35.00,
  gross_pay: 1300.00,
  net_pay: 1050.00,
  withholding_tax: 180.00,
  social_security_tax: 80.60,
  medicare_tax: 18.85,
  retirement_payment: 91.00
)

puts "Seed data successfully created."