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

require 'faker'

# Constants
EMPLOYEE_COUNT = 30
COMPANY_COUNT = 5

# Clear existing data
PayrollRecord.delete_all
Employee.delete_all
Company.delete_all

# Find the first Thursday of 2023
start_date = Date.new(2023, 1, 1)
start_date += (4 - start_date.wday) % 7 # Adjust to the first Thursday of 2023

# Calculate the most recent past Thursday
end_date = Date.today
end_date -= (end_date.wday - 4) % 7 # Adjust to the last Thursday

# Create companies with realistic American names
COMPANY_COUNT.times do
  company = Company.create!(
    name: Faker::Company.unique.name
  )

  puts "Created #{company.name}"

  EMPLOYEE_COUNT.times do
    # Randomly choose payroll type
    payroll_type = ['hourly', 'salary'].sample
    department = payroll_type == 'hourly' ? ['front_of_house', 'back_of_house'].sample : 'salary'

    # Generate employee attributes based on payroll type
    employee_attrs = {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      filing_status: ['single', 'married', 'head_of_household'].sample,
      department: department,
      payroll_type: payroll_type,
      retirement_rate: Faker::Number.between(from: 0, to: 10),
      roth_retirement_rate: Faker::Number.between(from: 0, to: 10)
    }

    # Set pay_rate for hourly employees
    employee_attrs[:pay_rate] = Faker::Number.decimal(l_digits: 2, r_digits: 2) if payroll_type == 'hourly'

    employee = company.employees.create!(employee_attrs)

    # Generate bi-weekly payroll records from the start of 2023 until the most recent past Thursday
    (start_date..end_date).step(14).each do |pay_date|
      if payroll_type == 'hourly'
        employee.payroll_records.create!(
          date: pay_date,
          hours_worked: Faker::Number.between(from: 0.01, to: 80), # Ensure hours_worked is at least 0.01
          overtime_hours_worked: Faker::Number.between(from: 0, to: 20),
          reported_tips: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          loan_payment: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          insurance_payment: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          gross_pay: nil, # Not used for hourly employees
          net_pay: nil, # Will be calculated
          withholding_tax: nil, # Will be calculated
          social_security_tax: nil, # Will be calculated
          medicare_tax: nil, # Will be calculated
          retirement_payment: nil, # Will be calculated
          roth_retirement_payment: nil # Will be calculated
        )
      else
        employee.payroll_records.create!(
          date: pay_date,
          hours_worked: nil, # Not used for salary employees
          overtime_hours_worked: nil, # Not used for salary employees
          reported_tips: nil, # Not used for salary employees
          loan_payment: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          insurance_payment: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          gross_pay: Faker::Number.decimal(l_digits: 4, r_digits: 2), # Set gross_pay for salary employees
          net_pay: nil, # Will be calculated
          withholding_tax: nil, # Will be calculated
          social_security_tax: nil, # Will be calculated
          medicare_tax: nil, # Will be calculated
          retirement_payment: nil, # Will be calculated
          roth_retirement_payment: nil # Will be calculated
        )
      end
    end

    puts "Created employee: #{employee.first_name} #{employee.last_name} (#{employee.payroll_type})"
  end
end

puts "Seeding completed!"
