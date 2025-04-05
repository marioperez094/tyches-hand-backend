json.id                  card.id
json.name                card.name
json.suit                card.suit
json.rank                card.rank
json.description         card.description
json.effect              card.effect
json.effect_values       card.effect_values
json.effect_description  EffectTypes::EFFECT_ACTIONS.dig(card.effect_type, :description) || "No description available"