# app/models/employee.rb
class Employee < ApplicationRecord
  has_many :payroll_records, dependent: :destroy
end
