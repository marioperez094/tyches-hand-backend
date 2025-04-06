json.array! player_cards do |card_effect|
  json.partial! 'api/cards/card', card: card_effect[:card]
  json.effects           card_effect[:effects].first
end