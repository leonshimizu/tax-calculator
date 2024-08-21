class Company < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :payroll_records, through: :employees

  validates :name, presence: true, uniqueness: true
end
