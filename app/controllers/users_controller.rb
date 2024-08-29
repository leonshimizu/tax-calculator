class UsersController < ApplicationController
  # Skip authentication checks for user creation
  skip_before_action :authenticate_user, only: [:create]
  skip_before_action :ensure_user_approved, only: [:create]

  # Creates a new user with a default status of 'pending'
  def create
    user = User.new(user_params.merge(status: 'pending')) # Use strong parameters and set status to 'pending'
    
    if user.save
      render json: { message: "User created successfully, awaiting approval." }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Show the current logged-in user's details
  def show_current_user
    if current_user
      render json: current_user.as_json(only: [:id, :name, :email, :status, :admin])
    else
      render json: { error: "No user logged in" }, status: :unauthorized
    end
  end

  private

  # Strong parameter method to whitelist allowed user attributes
  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
