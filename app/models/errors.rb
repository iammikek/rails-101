# frozen_string_literal: true

module Errors
  class AppError < StandardError
    attr_reader :code, :status

    def initialize(message, code:, status:)
      super(message)
      @code = code
      @status = status
    end
  end

  class ItemNotFound < AppError
    def initialize(item_id)
      super("Item #{item_id} not found", code: "ITEM_NOT_FOUND", status: :not_found)
    end
  end

  class CategoryNotFound < AppError
    def initialize(category_id)
      super("Category #{category_id} not found", code: "CATEGORY_NOT_FOUND", status: :not_found)
    end
  end

  class CategoryInUse < AppError
    def initialize(category_id)
      super(
        "Category has items and cannot be deleted",
        code: "CATEGORY_IN_USE",
        status: :conflict
      )
    end
  end

  class CategoryNameExists < AppError
    def initialize(name)
      super(
        "Category name '#{name}' already exists",
        code: "CATEGORY_NAME_EXISTS",
        status: :conflict
      )
    end
  end

  class UserEmailExists < AppError
    attr_reader :email

    def initialize(email)
      @email = email
      super(
        "User email '#{email}' already exists",
        code: "USER_EMAIL_EXISTS",
        status: :conflict
      )
    end
  end
end
