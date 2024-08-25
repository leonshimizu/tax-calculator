# app/models/custom_column.rb
class CustomColumn < ApplicationRecord
  belongs_to :company

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :data_type, inclusion: { in: %w[string integer decimal boolean date] }

  # Additional logic or methods if needed
end
