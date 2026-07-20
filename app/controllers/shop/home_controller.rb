# frozen_string_literal: true

module Shop
  class HomeController < BaseController
    def home
      @stats = ItemService.new.stats
    end
  end
end
