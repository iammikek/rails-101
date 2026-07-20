# frozen_string_literal: true

class Rack::Attack
  throttle("auth/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/auth/") && req.post?
  end

  throttle("writes/ip", limit: 60, period: 1.minute) do |req|
    if req.post? || req.patch? || req.put? || req.delete?
      next if req.path.start_with?("/shop")
      next if req.path.start_with?("/auth/")

      req.ip if req.path.match?(%r{\A/(items|categories)(/|\z)})
    end
  end

  self.throttled_responder = lambda do |_request|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { detail: "Rate limit exceeded", code: "RATE_LIMIT_EXCEEDED" }.to_json ]
    ]
  end
end
