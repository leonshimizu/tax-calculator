class Employee < ApplicationRecord
  belongs_to :company
  has_many :payroll_records, dependent: :destroy

  validates :retirement_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :pay_rate, presence: true, numericality: { greater_than_or_equal_to: 0.01 }, if: :hourly_employee?
  
  validates :payroll_type, presence: true, inclusion: { in: %w[hourly salaried] }

  def ytd_totals(year)
    payroll_records.where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31)).sum_fields
  end

  private

  def hourly_employee?
    payroll_type != 'salaried'
  end
end
