class Company < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :payroll_records, through: :employees
  has_many :custom_columns, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def department_ytd_totals(department, year)
    employees.where(department: department).joins(:payroll_records)
             .where(payroll_records: { date: Date.new(year, 1, 1)..Date.new(year, 12, 31) })
             .sum_fields
  end

  def company_ytd_totals(year)
    payroll_records.where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31)).sum_fields
  end
end
