json.name            player.deck.name
json.Total           player.cards.count

Card::EFFECTS.each do |effect|
  json.set! effect, player.cards.by_effect(effect).count
end