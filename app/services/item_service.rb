# frozen_string_literal: true

class ItemService
  def initialize(category_service: CategoryService.new)
    @category_service = category_service
  end

  def list_items(skip:, limit:, filters: {})
    scope = Item.includes(:category).order(:id)
    scope = apply_filters(scope, filters)
    total = scope.count
    rows = scope.offset(skip).limit(limit).to_a
    [ rows, total ]
  end

  def get_by_id!(item_id)
    Item.includes(:category).find_by(id: item_id) || raise(Errors::ItemNotFound.new(item_id))
  end

  def create!(name:, description:, price:, category_id:)
    category = category_id.nil? ? nil : @category_service.get_by_id!(category_id)
    item = Item.create!(
      name: name,
      description: description,
      price: price,
      category_id: category&.id
    )
    get_by_id!(item.id)
  end

  def update!(item_id, data)
    item = get_by_id!(item_id)

    item.name = data[:name].to_s if data.key?(:name) && !data[:name].nil?
    item.description = data[:description] if data.key?(:description)
    item.price = data[:price] if data.key?(:price) && !data[:price].nil?

    if data.key?(:category_id)
      if data[:category_id].nil?
        item.category_id = nil
      else
        item.category_id = @category_service.get_by_id!(data[:category_id].to_i).id
      end
    end

    item.save!
    get_by_id!(item_id)
  end

  def delete!(item_id)
    get_by_id!(item_id).destroy!
  end

  def stats
    total = Item.count
    if total.zero?
      return {
        total_items: 0,
        average_price: 0.0,
        min_price: nil,
        max_price: nil,
        uncategorized_count: 0,
        by_category: []
      }
    end

    aggregate = Item.pick(Arel.sql("AVG(price)"), Arel.sql("MIN(price)"), Arel.sql("MAX(price)"))
    uncategorized_count = Item.where(category_id: nil).count

    by_category = Item.joins(:category)
      .group("categories.id", "categories.name")
      .order("categories.name")
      .pluck(
        Arel.sql("categories.id"),
        Arel.sql("categories.name"),
        Arel.sql("COUNT(items.id)"),
        Arel.sql("AVG(items.price)")
      )
      .map do |category_id, category_name, item_count, average_price|
        {
          category_id: category_id.to_i,
          category_name: category_name,
          item_count: item_count.to_i,
          average_price: average_price.to_f.round(2)
        }
      end

    {
      total_items: total,
      average_price: aggregate[0].to_f.round(2),
      min_price: aggregate[1].to_f.round(2),
      max_price: aggregate[2].to_f.round(2),
      uncategorized_count: uncategorized_count,
      by_category: by_category
    }
  end

  private

  def apply_filters(scope, filters)
    scope = scope.where("price >= ?", filters[:min_price]) if filters[:min_price]
    scope = scope.where("price <= ?", filters[:max_price]) if filters[:max_price]
    scope = scope.where(category_id: filters[:category_id]) if filters[:category_id]
    if filters[:name_contains]
      scope = scope.where("LOWER(name) LIKE ?", "%#{filters[:name_contains].to_s.downcase}%")
    end
    scope
  end
end
