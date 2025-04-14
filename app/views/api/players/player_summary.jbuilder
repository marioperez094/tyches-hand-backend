json.player do
  json.partial! 'api/players/player', player: @player

  json.deck_breakdown do
    json.partial! 'api/players/deck_breakdown', player: @player
  end

  json.game_stats do
    json.partial! 'api/games/game_stats', player: @player
  end

  json.slots do
    json.array! @player.slots do |slot|
      json.partial! 'api/slots/slot', slot: slot
    end
  end
end