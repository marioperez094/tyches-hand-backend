json.wagered_health_statuses           @wagered_health_statuses

json.player_cards do
  json.array! @player_card_effects do |card|
    json.partial! 'api/hands/player_card', player_card: card
  end
end

json.daimon_cards do
  json.array! @daimon_cards do |card|
    json.partial! 'api/cards/card', card: card
  end
end


json.wager_dialogue                    @hand.round.daimon.dialogue.dig("wager", @hands_played.to_s)
json.hand_dialogue                     @hand.round.daimon.dialogue.dig("hand_count", @hands_played.to_s)
json.hands_played                      @hands_played
json.tyches_wrath                      @hands_played > 4
json.available_actions                 @actions
json.health_statuses                   @health_statuses