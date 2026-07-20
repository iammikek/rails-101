# frozen_string_literal: true

module ApiSerializer
  module_function

  def category(category)
    {
      id: category.id,
      name: category.name,
      description: category.description
    }
  end

  def item(item, include_category: true)
    data = {
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price.to_f,
      category_id: item.category_id
    }

    data[:category] = if include_category && item.category
      category(item.category)
    end

    data
  end

  def user(user)
    {
      id: user.id,
      email: user.email
    }
  end
end
