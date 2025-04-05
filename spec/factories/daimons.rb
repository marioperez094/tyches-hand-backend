FactoryBot.define do
  factory :daimon do
    name { 'The Thrill' }
    effect_type { 'damage_player' }
    effect_values {{ 'damage_player' => {
      'value' => 0.5,
      'apply_on_phase' => 'hand_start'
    }}}
    rune { 'Ω' }
    description { 'The thrill doesn not care if it wins or lose, it just looks for the excitement.' }

    intro { "Do you feel it? The excitement of the game, the height of the stakes, it's thrilling don't you think?" }
    player_win { "You may have won, but doesn't change how thrilling this was." }
    player_lose { "Seems like the thrill was too much." }
    
    dialogue{ ["Option 1.", "Option2.", "Option 3.", "Option 4.", "Option 5"] }
    story_sequence { 0 }
  end
end
