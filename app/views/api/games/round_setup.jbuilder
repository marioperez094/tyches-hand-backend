player = @game.player
round = @game.round
daimon = round.daimon

json.player do
  json.partial! 'api/players/player', player: player
  json.max_blood_pool      round.player_max_blood_pool
  
  json.slots do
    json.array! player.slots do |slot|
      json.partial! 'api/slots/slot', slot: slot
    end
  end
end

json.daimon do
  json.partial! 'api/daimons/daimon', daimon: daimon
  json.blood_pool   round.daimon_blood_pool
  json.max_blood_pool      round.daimon_max_blood_pool
end

json.round do
  json.status              round.status
end