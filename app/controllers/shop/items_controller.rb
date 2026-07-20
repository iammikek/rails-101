# frozen_string_literal: true

module Shop
  class ItemsController < BaseController
    PAGE_SIZE = 10

    before_action :require_login!, only: [ :new, :create ]

    def index
      filters = {}
      filters[:name_contains] = params[:name_contains] if params[:name_contains].present?
      filters[:category_id] = params[:category_id].to_i if params[:category_id].present?
      filters[:min_price] = params[:min_price] if params[:min_price].present?
      filters[:max_price] = params[:max_price] if params[:max_price].present?

      @page = [ params.fetch(:page, 1).to_i, 1 ].max
      skip = (@page - 1) * PAGE_SIZE

      @items, @total_count = ItemService.new.list_items(skip: skip, limit: PAGE_SIZE, filters: filters)
      @total_pages = [ (@total_count.to_f / PAGE_SIZE).ceil, 1 ].max
      @categories = Category.order(:name)
      @filters = params.to_unsafe_h.slice("name_contains", "category_id", "min_price", "max_price", "page")
    end

    def show
      @item = ItemService.new.get_by_id!(params[:id].to_i)
    end

    def new
      @categories = Category.order(:name)
    end

    def create
      @categories = Category.order(:name)
      category_id = params[:category_id].presence&.to_i

      item = ItemService.new.create!(
        name: params[:name].to_s,
        description: params[:description].presence,
        price: format("%.2f", params[:price].to_f),
        category_id: category_id
      )

      redirect_to shop_item_path(item), notice: %(Created "#{item.name}".)
    rescue Errors::CategoryNotFound, ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end
  end
end
