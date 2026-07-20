# frozen_string_literal: true

module Shop
  class BaseController < ApplicationController
    layout "shop"

    rescue_from ::Errors::ItemNotFound, ::Errors::CategoryNotFound do
      raise ActionController::RoutingError, "Not Found"
    end

    private

    def require_login!
      return if session[:user_id] && current_shop_user

      redirect_to shop_login_path, alert: "Please log in to continue."
    end

    def current_shop_user
      @current_shop_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
    helper_method :current_shop_user
  end
end
