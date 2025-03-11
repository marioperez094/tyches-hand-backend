json.name            player.deck.name
json.Total           player.cards.count

Card::EFFECTS.each do |effect|
  details = CardEffectCalculator::EFFECT_DETAILS[effect]

  json.set! effect, {
    count: player.cards.by_effect(effect).count,
    description: details&.dig(:description) || "A standard deck of cards, they are almost boring with how ordinary they appear.",
    effect_description: details&.dig(:effect_description) || "No effect."
  }
end