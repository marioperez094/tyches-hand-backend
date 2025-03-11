json.id          slot.id
json.slot_type   slot.slot_type

if slot.token
  json.token do
    json.partial! 'api/tokens/token', token: slot.token
  end
end