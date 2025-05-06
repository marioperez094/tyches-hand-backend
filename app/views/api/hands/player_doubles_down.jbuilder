json.wagered_health_statuses           @wagered_health_statuses

json.player_card do
  json.partial! 'api/hands/player_card', player_card: @player_hits.first
end

json.daimon_cards do
  json.array! @daimon_cards do |card|
    json.partial! 'api/cards/card', card: card
  end
end

json.health_statuses                  @health_statuses