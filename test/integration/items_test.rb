# frozen_string_literal: true

require "test_helper"

class ItemsTest < ApiTestCase
  test "create item" do
    token = create_authenticated_token
    post "/items",
         params: { name: "Widget", description: "A nice widget", price: 9.99 }.to_json,
         headers: bearer_headers(token).merge("Content-Type" => "application/json")

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Widget", body["name"]
    assert_equal "A nice widget", body["description"]
    assert_in_delta 9.99, body["price"], 0.001
    assert body["id"] >= 1
  end

  test "create item without auth" do
    post "/items",
         params: { name: "Widget", price: 9.99 }.to_json,
         headers: { "Content-Type" => "application/json" }
    assert_response :unauthorized
  end

  test "get item not found" do
    get "/items/99"
    assert_response :not_found
    assert_equal "ITEM_NOT_FOUND", JSON.parse(response.body)["code"]
  end

  test "list items with pagination metadata" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")
    post "/items", params: { name: "A", price: 1.0 }.to_json, headers: headers
    post "/items", params: { name: "B", price: 2.0 }.to_json, headers: headers

    get "/items?skip=0&limit=1"
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body["total"]
    assert_equal 0, body["skip"]
    assert_equal 1, body["limit"]
    assert_equal 1, body["items"].length
  end

  test "filter items by name_contains" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")
    post "/items", params: { name: "Red Widget", price: 1.0 }.to_json, headers: headers
    post "/items", params: { name: "Blue Gadget", price: 2.0 }.to_json, headers: headers

    get "/items?name_contains=widget"
    body = JSON.parse(response.body)
    assert_equal 1, body["total"]
    assert_equal "Red Widget", body["items"][0]["name"]
  end

  test "item stats summary" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")

    post "/categories", params: { name: "Tools" }.to_json, headers: headers
    category_id = JSON.parse(response.body)["id"]

    post "/items",
         params: { name: "Hammer", price: 10.0, category_id: category_id }.to_json,
         headers: headers
    post "/items", params: { name: "Misc", price: 5.0 }.to_json, headers: headers

    get "/items/stats/summary"
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body["total_items"]
    assert_equal 1, body["uncategorized_count"]
    assert_equal 1, body["by_category"].length
  end

  test "delete item" do
    token = create_authenticated_token
    headers = bearer_headers(token).merge("Content-Type" => "application/json")
    post "/items", params: { name: "To Delete", price: 1.0 }.to_json, headers: headers
    item_id = JSON.parse(response.body)["id"]

    delete "/items/#{item_id}", headers: bearer_headers(token)
    assert_response :no_content

    get "/items/#{item_id}"
    assert_response :not_found
  end
end
