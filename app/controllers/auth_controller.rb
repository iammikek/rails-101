# frozen_string_literal: true

class AuthController < ApiController
  include JwtAuthenticatable

  before_action :authenticate_jwt!, only: [ :me ]

  def register
    email = json_body[:email].to_s
    password = json_body[:password].to_s

    if email.blank? || password.blank?
      return render json: { detail: "email and password are required" }, status: :unprocessable_entity
    end

    if password.length < 8 || password.length > 128
      return render json: { detail: "password must be between 8 and 128 characters" }, status: :unprocessable_entity
    end

    user = UserService.new.create!(email: email, password: password)
    render json: ApiSerializer.user(user), status: :created
  end

  def login
    email = params[:username].presence || params[:email].presence || json_body[:username].presence || json_body[:email].presence
    password = params[:password].presence || json_body[:password].presence

    user = UserService.new.authenticate(email: email.to_s, password: password.to_s)
    if user.nil?
      response.set_header("WWW-Authenticate", "Bearer")
      return render json: { detail: "Incorrect email or password" }, status: :unauthorized
    end

    render json: {
      access_token: JwtService.encode(user),
      token_type: "bearer"
    }
  end

  def me
    render json: ApiSerializer.user(current_user)
  end
end
