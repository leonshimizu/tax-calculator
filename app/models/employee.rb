# app/models/employee.rb
class Employee < ApplicationRecord
  has_many :payroll_records, dependent: :destroy
  validates :retirement_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :pay_rate, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
end
