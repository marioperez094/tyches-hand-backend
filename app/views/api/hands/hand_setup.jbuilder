round = @hand.round
player = round.game.player
daimon = round.daimon

json.player_health                      player.blood_pool
json.daimon_health                      round.daimon_blood_pool
json.blood_wager                        @hand.blood_wager

json.player_cards do
  json.array! @hand.player_hand_cards do |card|
    json.partial! 'api/cards/card', card: card
  end
end

json.daimon_cards do
  json.array! @hand.daimon_hand_cards do |card|
    json.partial! 'api/cards/card', card: card
  end
end

json.hands_played                      round.hands_played
json.tyches_wrath                      round.tyches_wrath_active?
json.dialogue                          round.hand_setup_dialogue
json.player_actions                    @hand_service.available_player_actions