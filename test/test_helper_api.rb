# frozen_string_literal: true

require "test_helper"

class ApiTestCase < ActionDispatch::IntegrationTest
  def create_user(email: "test@example.com", password: "secret123")
    UserService.new.create!(email: email, password: password)
  end

  def create_authenticated_token(email: "test@example.com", password: "secret123")
    create_user(email: email, password: password)
    JwtService.encode(User.find_by!(email: email))
  end

  def bearer_headers(token)
    { "Authorization" => "Bearer #{token}", "Accept" => "application/json" }
  end
end
