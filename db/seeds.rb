# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Employee.create([
  {
    name: "Alice Johnson",
    filing_status: "single",
    pay_rate: 25.50,
    retirement_rate: 0.05,
    position: "front_of_house"
  },
  {
    name: "Bob Smith",
    filing_status: "married",
    pay_rate: 22.00,
    retirement_rate: 0.07,
    position: "back_of_house"
  },
  {
    name: "Carol White",
    filing_status: "married",
    pay_rate: 30.00,
    retirement_rate: 0.06,
    position: "front_of_house"
  },
  {
    name: "David Brown",
    filing_status: "single",
    pay_rate: 18.00,
    retirement_rate: 0.04,
    position: "back_of_house"
  }
])

# Might need to adjust employee_id based on your actual Employee records in the database
PayrollRecord.create([
  {
    employee_id: 1, # Assuming Alice's ID is 1
    hours_worked: 40,
    overtime_hours_worked: 5,
    reported_tips: 120.50,
    loan_payment: 50,
    insurance_payment: 75,
    date: Date.today
  },
  {
    employee_id: 2, # Assuming Bob's ID is 2
    hours_worked: 40,
    overtime_hours_worked: 3,
    reported_tips: 80.00,
    loan_payment: 0,
    insurance_payment: 90,
    date: Date.today
  },
  {
    employee_id: 3, # Assuming Carol's ID is 3
    hours_worked: 38,
    overtime_hours_worked: 2,
    reported_tips: 200.00,
    loan_payment: 0,
    insurance_payment: 60,
    date: Date.today
  },
  {
    employee_id: 4, # Assuming David's ID is 4
    hours_worked: 42,
    overtime_hours_worked: 6,
    reported_tips: 95.25,
    loan_payment: 100,
    insurance_payment: 50,
    date: Date.today
  }
])
