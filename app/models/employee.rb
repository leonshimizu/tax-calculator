# app/models/employee.rb
class Employee < ApplicationRecord
  has_many :payroll_records, dependent: :destroy
  before_save :convert_retirement_rate_to_percentage
  validates :retirement_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :name, presence: true
  validates :pay_rate, presence: true, numericality: { greater_than_or_equal_to: 0.01 }

  private

  def convert_retirement_rate_to_percentage
    # Assuming the user inputs a whole number for the percentage
    self.retirement_rate = retirement_rate / 100.0 unless retirement_rate.blank?
  end
end
