# frozen_string_literal: true

require "test_helper"

class HealthTest < ApiTestCase
  test "root" do
    get "/"
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "Hello from rails-101", body["message"]
  end

  test "health" do
    get "/health"
    assert_response :success
    assert_equal({ "status" => "ok" }, JSON.parse(response.body))
  end
end
