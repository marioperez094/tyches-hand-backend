class Rack::Attack
  # Throttle requests to `/api/v1/players` (limit: 5 per 60 seconds)
  throttle('create_account', limit: 5, period: 60.seconds) do |req|
    if req.path == '/api/v1/players' && req.post?
      req.ip
    end
  end
end