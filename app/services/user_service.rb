# frozen_string_literal: true

class UserService
  def get_by_email(email)
    User.find_by(email: email.to_s.strip.downcase)
  end

  def create!(email:, password:)
    if get_by_email(email)
      raise Errors::UserEmailExists.new(email)
    end

    User.create!(email: email, password: password)
  end

  def authenticate(email:, password:)
    user = get_by_email(email)
    return nil unless user&.authenticate(password)

    user
  end
end
