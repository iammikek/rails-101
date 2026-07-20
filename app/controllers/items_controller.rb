# frozen_string_literal: true

class ItemsController < ApiController
  include JwtAuthenticatable

  before_action :authenticate_jwt!, only: [ :create, :update, :destroy ]

  def index
    skip = [ params.fetch(:skip, 0).to_i, 0 ].max
    limit = params.fetch(:limit, 10).to_i.clamp(1, 100)

    filters = {}
    filters[:min_price] = params[:min_price] if params.key?(:min_price)
    filters[:max_price] = params[:max_price] if params.key?(:max_price)
    filters[:category_id] = params[:category_id].to_i if params.key?(:category_id)
    filters[:name_contains] = params[:name_contains] if params[:name_contains].present?

    rows, total = ItemService.new.list_items(skip: skip, limit: limit, filters: filters)

    render json: {
      items: rows.map { |item| ApiSerializer.item(item) },
      total: total,
      skip: skip,
      limit: limit
    }
  end

  def stats
    render json: ItemService.new.stats
  end

  def show
    render json: ApiSerializer.item(ItemService.new.get_by_id!(params[:id].to_i))
  end

  def create
    body = json_body
    name = body[:name].to_s
    price = body[:price]

    if name.blank? || price.blank?
      return render json: { detail: "name and price are required" }, status: :unprocessable_entity
    end

    if price.to_f <= 0
      return render json: { detail: "price must be greater than 0" }, status: :unprocessable_entity
    end

    item = ItemService.new.create!(
      name: name,
      description: body[:description],
      price: format("%.2f", price.to_f),
      category_id: body[:category_id]&.to_i
    )

    render json: ApiSerializer.item(item), status: :created
  end

  def update
    body = json_body
    data = body.slice(:name, :description, :price, :category_id)
    data[:price] = format("%.2f", data[:price].to_f) if data.key?(:price) && !data[:price].nil?

    item = ItemService.new.update!(params[:id].to_i, data)
    render json: ApiSerializer.item(item)
  end

  def destroy
    ItemService.new.delete!(params[:id].to_i)
    head :no_content
  end
end
