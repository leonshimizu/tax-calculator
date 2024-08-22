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

# Create companies
companies = Company.create!([
  { name: 'Tech Innovators Inc.', },
  { name: 'Green Solutions Ltd.', },
  { name: 'Health First Corp.' }
])

# Create employees
employees = []

employees += Employee.create!([
  { first_name: 'John', last_name: 'Doe', payroll_type: 'hourly', department: 'front_of_house', pay_rate: 25.00, retirement_rate: 5.0, filing_status: 'single', company: companies[0] },
  { first_name: 'Jane', last_name: 'Smith', payroll_type: 'hourly', department: 'back_of_house', pay_rate: 22.00, retirement_rate: 6.0, filing_status: 'married', company: companies[0] },
  { first_name: 'Michael', last_name: 'Johnson', payroll_type: 'salary', department: 'salary', retirement_rate: 4.0, filing_status: 'head_of_household', company: companies[0] },
  { first_name: 'Emily', last_name: 'Davis', payroll_type: 'salary', department: 'salary', retirement_rate: 7.0, filing_status: 'single', company: companies[1] },
  { first_name: 'David', last_name: 'Brown', payroll_type: 'hourly', department: 'administration', pay_rate: 30.00, retirement_rate: 5.5, filing_status: 'married', company: companies[1] },
  { first_name: 'Sarah', last_name: 'Miller', payroll_type: 'salary', department: 'salary', retirement_rate: 6.0, filing_status: 'single', company: companies[2] },
  { first_name: 'James', last_name: 'Wilson', payroll_type: 'hourly', department: 'front_of_house', pay_rate: 28.00, retirement_rate: 3.5, filing_status: 'married', company: companies[2] },
  { first_name: 'Linda', last_name: 'Martinez', payroll_type: 'hourly', department: 'back_of_house', pay_rate: 24.00, retirement_rate: 4.5, filing_status: 'head_of_household', company: companies[2] }
])

# Create payroll records for employees
payroll_records = []

employees.each do |employee|
  10.times do
    if employee.payroll_type == 'hourly'
      payroll_records << PayrollRecord.create!(
        employee: employee,
        date: Faker::Date.backward(days: 365),
        hours_worked: rand(30..50),
        overtime_hours_worked: rand(0..10),
        reported_tips: rand(50..200),
        loan_payment: rand(50..100),
        insurance_payment: rand(100..200)
      )
    else
      payroll_records << PayrollRecord.create!(
        employee: employee,
        date: Faker::Date.backward(days: 365),
        gross_pay: rand(4000..6000),
        bonus: rand(500..1000),
        loan_payment: rand(50..100),
        insurance_payment: rand(100..200)
      )
    end
  end
end

puts "Seeded #{Company.count} companies, #{Employee.count} employees, and #{PayrollRecord.count} payroll records."
