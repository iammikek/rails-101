# frozen_string_literal: true

require "test_helper"

class ShopTest < ActionDispatch::IntegrationTest
  test "shop home renders" do
    get "/shop"
    assert_response :success
    assert_match "Catalog Shop", response.body
  end

  test "shop register and add item" do
    get "/shop/register"
    assert_response :success

    post "/shop/register", params: {
      email: "shopper@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
    assert_redirected_to shop_home_path
    follow_redirect!
    assert_response :success

    get "/shop/items/new"
    assert_response :success

    post "/shop/items/new", params: {
      name: "Shop Widget",
      description: "From the shop",
      price: "12.50"
    }
    assert_response :redirect
    follow_redirect!
    assert_match "Shop Widget", response.body
  end

  test "shop items new requires login" do
    get "/shop/items/new"
    assert_redirected_to shop_login_path
  end
end
