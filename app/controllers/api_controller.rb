# frozen_string_literal: true

class ApiController < ApplicationController
  skip_forgery_protection

  rescue_from ::Errors::AppError do |error|
    render json: { detail: error.message, code: error.code }, status: error.status
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { detail: error.message }, status: :unprocessable_entity
  end

  private

  def json_body
    body = request.request_parameters
    body = request.params if body.blank?
    body = body.to_unsafe_h if body.respond_to?(:to_unsafe_h)
    body.is_a?(Hash) ? body.with_indifferent_access : {}
  end
end
