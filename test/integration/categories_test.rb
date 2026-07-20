# frozen_string_literal: true

require "test_helper"

class CategoriesTest < ApiTestCase
  test "create category" do
    token = create_authenticated_token
    post "/categories",
         params: { name: "Tools", description: "Hand tools" }.to_json,
         headers: bearer_headers(token).merge("Content-Type" => "application/json")

    assert_response :created
    body = JSON.parse(response.body)
    assert body["id"] >= 1
    assert_equal "Tools", body["name"]
    assert_equal "Hand tools", body["description"]
  end

  test "create category without auth" do
    post "/categories",
         params: { name: "Tools" }.to_json,
         headers: { "Content-Type" => "application/json" }
    assert_response :unauthorized
  end

  test "create category duplicate name" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")
    post "/categories", params: { name: "foo" }.to_json, headers: headers
    assert_response :created

    post "/categories", params: { name: "foo", description: "duplicate" }.to_json, headers: headers
    assert_response :conflict
    assert_equal "CATEGORY_NAME_EXISTS", JSON.parse(response.body)["code"]
  end

  test "list categories" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")
    post "/categories", params: { name: "Books" }.to_json, headers: headers

    get "/categories"
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["total"]
    assert_equal "Books", body["items"][0]["name"]
  end

  test "delete category in use" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")
    post "/categories", params: { name: "Used" }.to_json, headers: headers
    category_id = JSON.parse(response.body)["id"]
    post "/items",
         params: { name: "Thing", price: 1.0, category_id: category_id }.to_json,
         headers: headers

    delete "/categories/#{category_id}", headers: bearer_headers(token)
    assert_response :conflict
    assert_equal "CATEGORY_IN_USE", JSON.parse(response.body)["code"]
  end
end
