# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  # Check if the user is approved
  def approved?
    self.status == 'approved'
  end

  # Check if the user is an admin
  def admin?
    self.admin
  end
end
