# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user # Ensure every request checks for an authenticated user
  before_action :ensure_user_approved, except: [:create] # Ensure user is approved, except for the 'create' action

  # Memoize the current_user method to avoid multiple database calls
  def current_user
    return @current_user if defined?(@current_user) # Avoid repeated calls

    token = auth_token_from_header
    if token
      @current_user = find_user_from_token(token)
    else
      @current_user = nil
    end
  end

  # Checks if a user is authenticated
  def authenticate_user
    unless current_user
      render json: { error: "Unauthorized access" }, status: :unauthorized
    end
  end

  # Ensures that only approved users can access the application
  def ensure_user_approved
    if current_user.nil?
      render json: { error: "Unauthorized access" }, status: :unauthorized
    elsif !current_user.approved?
      render json: { error: "Your account is pending approval. Please contact the administrator." }, status: :forbidden
    end
  end

  # Checks if the current user is an admin
  def authenticate_admin!
    unless current_user&.admin?
      render json: { error: "Access restricted to administrators only." }, status: :forbidden
    end
  end

  private

  # Extract the token from the Authorization header
  def auth_token_from_header
    auth_headers = request.headers["Authorization"]
    return auth_headers[/(?<=\A(Bearer ))\S+\z/] if auth_headers.present?
    nil
  end

  # Decode the JWT token and find the user
  def find_user_from_token(token)
    decoded_token = JWT.decode(
      token,
      Rails.application.credentials.fetch(:secret_key_base),
      true,
      { algorithm: "HS256" }
    )
    User.find_by(id: decoded_token[0]["user_id"])
  rescue JWT::ExpiredSignature, JWT::DecodeError => e
    Rails.logger.warn("JWT Decode Error: #{e.message}")
    nil
  end
end
