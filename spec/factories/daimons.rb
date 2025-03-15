FactoryBot.define do
  factory :daimon do
    name { 'The Thrill' }
    effect_type { 'double_wager' }
    rune { 'Ω' }

    intro { "Do you feel it? The excitement of the game, the height of the stakes, it's thrilling don't you think?" }
    player_win { "You may have won, but doesn't change how thrilling this was." }
    player_lose { "Seems like the thrill was too much." }
    
    taunts{ ["You can't deny how exciting this is, make your choice.", "Why stop now, things will only get more interesting."] }
  end
end
