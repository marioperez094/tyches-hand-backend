json.player do
  json.partial! 'api/players/player', player: @player

  if @include_deck_stats
    json.deck do
      json.partial! 'api/players/card_stats', player: @player
    end
  end

  if @include_deck_cards
    json.deck_cards do
      json.array! @player.equipped_cards do |card|
        json.partial! 'api/cards/card', card: card
      end
    end
  end

  if @include_collection_cards
    json.collection_cards do
      json.array! @player.cards.where.not(id: @player.equipped_cards.select(:id)) do |card|
        json.partial! 'api/cards/card', card: card
      end
    end
  end

  if @include_collection_tokens
    json.total_tokens @player.tokens.count
    json.collection_tokens do
      json.array! @player.tokens.where.not(id: @player.loadout_tokens.select(:id)) do |token|
        json.partial! 'api/tokens/token', token: token
      end
    end
  end

  if @include_slots
    json.slots do
      json.array! @player.slots do |slot|
        json.partial! 'api/slots/slot', slot: slot
      end
    end
  end
end