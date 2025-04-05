json.game do
  json.partial! 'api/games/game_stats', game: @game
end