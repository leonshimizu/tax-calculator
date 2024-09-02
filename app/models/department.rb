# app/models/department.rb
class Department < ApplicationRecord
  belongs_to :company
  has_many :employees, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :company_id, presence: true
end
