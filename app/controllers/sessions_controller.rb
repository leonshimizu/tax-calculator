# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [:create, :refresh]

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if user.approved?  # Correctly use the approved? method
        jwt = generate_token(user)
        render json: { jwt: jwt, email: user.email, user_id: user.id }, status: :created
      else
        render json: { error: "Account not approved. Please contact the administrator." }, status: :forbidden
      end
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def refresh
    token = auth_token_from_header
    decoded_token = JWT.decode(token, Rails.application.credentials.fetch(:secret_key_base), true, { algorithm: 'HS256' })
    user = User.find_by(id: decoded_token[0]['user_id'])

    if user && user.approved?
      new_jwt = generate_token(user)
      render json: { jwt: new_jwt }, status: :ok
    else
      render json: { error: 'Unauthorized access' }, status: :unauthorized
    end
  rescue JWT::ExpiredSignature, JWT::DecodeError
    render json: { error: 'Token expired or invalid' }, status: :unauthorized
  end

  private

  def generate_token(user)
    JWT.encode(
      { user_id: user.id, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.fetch(:secret_key_base),
      'HS256'
    )
  end
end
