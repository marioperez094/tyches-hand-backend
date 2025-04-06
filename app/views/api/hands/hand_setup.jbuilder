json.hand_setup           @hand_setup

json.player_cards do
  json.partial! 'api/hands/player_card', player_cards: @player_card_effect
end

json.daimon_cards do
  json.array! @daimon_cards do |card|
    json.partial! 'api/cards/card', card: card
  end
end