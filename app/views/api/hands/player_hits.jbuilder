json.player_card do
  json.partial! 'api/hands/player_card', player_card: @player_hits.first
end

json.available_actions           @actions
json.results                     @resolve_hand