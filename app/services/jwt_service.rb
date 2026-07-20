# frozen_string_literal: true

module JwtService
  module_function

  ALGORITHM = "HS256"

  def encode(user)
    payload = {
      sub: user.id,
      email: user.email,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, secret, ALGORITHM)
  end

  def decode(token)
    JWT.decode(token, secret, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError
    nil
  end

  def secret
    ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  end
end
