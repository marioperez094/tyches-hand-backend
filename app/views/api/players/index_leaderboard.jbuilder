json.players do
  json.array! @players do |player|
    json.username                   player.username
    json.max_round_reached          player.max_round_reached
    json.max_daimon_health_reached  player.max_daimon_health_reached
  end
end