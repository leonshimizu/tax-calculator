# db/seeds.rb

require 'faker'

# Constants
EMPLOYEE_COUNT = 30

# Clear existing data
# Ensure we delete dependent records in the correct order to avoid foreign key violations
PayrollRecord.delete_all
EmployeeYtdTotal.delete_all # Clear YTD totals before employees to avoid foreign key violations
Employee.delete_all
Department.delete_all
Company.delete_all

# Specified company names
company_names = [
  'Aire Services',
  'Hafaloha',
  'Stax',
  'Ambros Inc.',
  'Shimizu Tax Company'
]

# Find the first Thursday of 2023
start_date = Date.new(2023, 1, 1)
start_date += (4 - start_date.wday) % 7 # Adjust to the first Thursday of 2023

# Calculate the most recent past Thursday
end_date = Date.today
end_date -= (end_date.wday - 4) % 7 # Adjust to the last Thursday

# Create companies with the specified names
company_names.each do |company_name|
  company = Company.create!(
    name: company_name
  )

  puts "Created #{company.name}"

  # Create departments for the company
  departments = {
    'front_of_house' => company.departments.create!(name: 'Front of House'),
    'back_of_house' => company.departments.create!(name: 'Back of House'),
    'salary' => company.departments.create!(name: 'Salary')
  }

  EMPLOYEE_COUNT.times do
    # Randomly choose payroll type
    payroll_type = ['hourly', 'salary'].sample
    department_name = payroll_type == 'hourly' ? ['front_of_house', 'back_of_house'].sample : 'salary'
    department = departments[department_name] # Use the appropriate department

    # Generate employee attributes based on payroll type
    employee_attrs = {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      filing_status: ['single', 'married', 'head_of_household'].sample,
      payroll_type: payroll_type,
      retirement_rate: Faker::Number.between(from: 0, to: 10),
      roth_retirement_rate: Faker::Number.between(from: 0, to: 10),
      department_id: department.id # Assign department_id
    }

    # Set pay_rate for hourly employees
    employee_attrs[:pay_rate] = Faker::Number.decimal(l_digits: 2, r_digits: 2) if payroll_type == 'hourly'

    employee = company.employees.create!(employee_attrs)

    # Create a corresponding Employee YTD Total record
    # Adjust these attributes to match what's in your EmployeeYtdTotal model
    EmployeeYtdTotal.create!(
      employee_id: employee.id
      # Add or adjust the attributes here based on what exists in your EmployeeYtdTotal model
    )

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
