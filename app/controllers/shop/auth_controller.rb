# frozen_string_literal: true

module Shop
  class AuthController < BaseController
    def login
      redirect_to shop_home_path and return if current_shop_user

      return unless request.post?

      user = UserService.new.authenticate(email: params[:email].to_s, password: params[:password].to_s)
      if user
        reset_session
        session[:user_id] = user.id
        redirect_to shop_home_path
      else
        flash.now[:alert] = "Invalid credentials."
        render :login, status: :unprocessable_entity
      end
    end

    def logout
      reset_session
      redirect_to shop_home_path
    end

    def register
      redirect_to shop_home_path and return if current_shop_user

      return unless request.post?

      password = params[:password].to_s
      confirmation = params[:password_confirmation].to_s

      if password != confirmation
        flash.now[:alert] = "Password confirmation does not match."
        return render :register, status: :unprocessable_entity
      end

      begin
        user = UserService.new.create!(email: params[:email].to_s, password: password)
      rescue Errors::UserEmailExists
        flash.now[:alert] = "An account with this email already exists."
        return render :register, status: :unprocessable_entity
      end

      reset_session
      session[:user_id] = user.id
      redirect_to shop_home_path, notice: "Account created. You are logged in."
    end
  end
end
