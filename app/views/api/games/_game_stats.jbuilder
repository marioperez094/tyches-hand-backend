game = player&.game

json.games_played            player.games_played 
json.hands_won               game&.total_hands_won || 0
json.hands_lost              game&.total_hands_lost || 0
json.current_streak          game&.win_streak || 0
json.longest_win_streak      game&.longest_win_streak || 0