# frozen_string_literal: true

require "test_helper"

class AuthTest < ApiTestCase
  test "register user" do
    post "/auth/register",
         params: { email: "alice@example.com", password: "password123" }.to_json,
         headers: { "Content-Type" => "application/json" }

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "alice@example.com", body["email"]
    assert_nil body["password"]
  end

  test "register duplicate email" do
    payload = { email: "test@example.com", password: "secret123" }
    post "/auth/register", params: payload.to_json, headers: { "Content-Type" => "application/json" }
    assert_response :created

    post "/auth/register", params: payload.to_json, headers: { "Content-Type" => "application/json" }
    assert_response :conflict
    assert_equal "USER_EMAIL_EXISTS", JSON.parse(response.body)["code"]
  end

  test "login success" do
    post "/auth/register",
         params: { email: "test@example.com", password: "secret123" }.to_json,
         headers: { "Content-Type" => "application/json" }

    post "/auth/login", params: { username: "test@example.com", password: "secret123" }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "bearer", body["token_type"]
    assert body["access_token"].present?
  end

  test "login invalid password" do
    post "/auth/register",
         params: { email: "test@example.com", password: "secret123" }.to_json,
         headers: { "Content-Type" => "application/json" }

    post "/auth/login", params: { username: "test@example.com", password: "wrong-password" }
    assert_response :unauthorized
    assert_equal "Incorrect email or password", JSON.parse(response.body)["detail"]
  end

  test "read current user" do
    token = create_authenticated_token
    get "/auth/me", headers: bearer_headers(token)
    assert_response :success
    assert_equal "test@example.com", JSON.parse(response.body)["email"]
  end

  test "read current user without token" do
    get "/auth/me"
    assert_response :unauthorized
  end
end
