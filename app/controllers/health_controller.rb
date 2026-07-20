# frozen_string_literal: true

class HealthController < ApiController
  def root
    render json: {
      message: "Hello from rails-101",
      docs: "See README.md — JSON API + /shop ERB UI"
    }
  end

  def health
    render json: { status: "ok" }
  end
end
