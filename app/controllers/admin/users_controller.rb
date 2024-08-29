# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  before_action :authenticate_user
  before_action :authenticate_admin!
  skip_before_action :ensure_user_approved # Skip approval check for admin actions

  def index
    pending_users = User.where(status: 'pending')
    render json: pending_users
  end

  def update
    user = User.find_by(id: params[:id]) # Use find_by to avoid exceptions

    if user.nil?
      render json: { error: 'User not found.' }, status: :not_found
    elsif user.update(user_params) # Use strong parameters
      send_status_notification(user) # Call the helper method to send email based on status
      render json: { message: 'User status updated successfully.' }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Use strong parameters for security
  def user_params
    params.require(:user).permit(:status)
  end

  # Helper method to send email based on user status
  def send_status_notification(user)
    if user.status == 'approved'
      UserMailer.approval_notification(user).deliver_now
    elsif user.status == 'rejected'
      UserMailer.rejection_notification(user).deliver_now
    end
  rescue StandardError => e
    Rails.logger.error("Failed to send status notification: #{e.message}")
    # Optionally, render an error response or handle the error as needed
  end
end
