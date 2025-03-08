json.tokens do
  json.array! @tokens do |token|
    json.partial! 'api/tokens/token', token: token
  end
end