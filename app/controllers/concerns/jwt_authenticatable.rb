# frozen_string_literal: true

module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_jwt!
    token = bearer_token
    if token.blank?
      return render json: { detail: "Unauthorized" }, status: :unauthorized
    end

    payload = JwtService.decode(token)
    user = payload && User.find_by(id: payload["sub"])
    if user.nil?
      return render json: { detail: "Unauthorized" }, status: :unauthorized
    end

    @current_user = user
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    return header.delete_prefix("Bearer ").strip if header.start_with?("Bearer ")

    nil
  end
end
