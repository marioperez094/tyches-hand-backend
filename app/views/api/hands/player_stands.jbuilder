json.daimon_cards do
  json.array! @daimon_cards do |card|
    json.partial! 'api/cards/card', card: card
  end
end

json.health_statuses           @health_statuses