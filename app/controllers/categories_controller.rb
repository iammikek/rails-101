# frozen_string_literal: true

class CategoriesController < ApiController
  include JwtAuthenticatable

  before_action :authenticate_jwt!, only: [ :create, :update, :destroy ]

  def index
    skip = [ params.fetch(:skip, 0).to_i, 0 ].max
    limit = params.fetch(:limit, 10).to_i.clamp(1, 100)

    rows, total = CategoryService.new.list_categories(skip: skip, limit: limit)

    render json: {
      items: rows.map { |row| ApiSerializer.category(row) },
      total: total,
      skip: skip,
      limit: limit
    }
  end

  def show
    render json: ApiSerializer.category(CategoryService.new.get_by_id!(params[:id].to_i))
  end

  def create
    body = json_body
    name = body[:name].to_s
    if name.blank?
      return render json: { detail: "name is required" }, status: :unprocessable_entity
    end

    category = CategoryService.new.create!(name: name, description: body[:description])
    render json: ApiSerializer.category(category), status: :created
  end

  def update
    category = CategoryService.new.update!(params[:id].to_i, json_body.slice(:name, :description))
    render json: ApiSerializer.category(category)
  end

  def destroy
    CategoryService.new.delete!(params[:id].to_i)
    head :no_content
  end
end
