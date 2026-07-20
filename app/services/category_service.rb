# frozen_string_literal: true

class CategoryService
  def list_categories(skip:, limit:)
    scope = Category.order(:id)
    total = scope.count
    rows = scope.offset(skip).limit(limit).to_a
    [ rows, total ]
  end

  def get_by_id!(category_id)
    Category.find_by(id: category_id) || raise(Errors::CategoryNotFound.new(category_id))
  end

  def create!(name:, description:)
    ensure_unique_name!(name)
    Category.create!(name: name, description: description)
  end

  def update!(category_id, data)
    category = get_by_id!(category_id)

    if data.key?(:name) && !data[:name].nil?
      ensure_unique_name!(data[:name].to_s, exclude_id: category_id)
      category.name = data[:name].to_s
    end

    category.description = data[:description] if data.key?(:description)
    category.save!
    category
  end

  def delete!(category_id)
    category = get_by_id!(category_id)
    if Item.exists?(category_id: category.id)
      raise Errors::CategoryInUse.new(category_id)
    end
    category.destroy!
  end

  private

  def ensure_unique_name!(name, exclude_id: nil)
    scope = Category.where(name: name)
    scope = scope.where.not(id: exclude_id) if exclude_id
    raise Errors::CategoryNameExists.new(name) if scope.exists?
  end
end
