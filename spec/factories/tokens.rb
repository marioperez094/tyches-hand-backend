FactoryBot.define do
  factory :token do
    name { 'Red Tearstone Token' }
    rune { 'Θ' }
    description { 'Tyche rewards those who dare play the odds - for a great wager deserves a great reward. But be certain you can withstand the cost.' }
    inscribed_effect_type { 'damage_daimon_limit_health' }
    inscribed_effect_values {{ 
      'damage_daimon_with_difference' => {
          'value' => -0.15,
          'apply_on_phase' => 'hand_start'
        },
        'player_max_health' => {
          'value' => 0.2,
          'apply_on_phase' => 'round_start'
        }
    }}
    oathbound_effect_type { 'damage_daimon_and_player' }
    oathbound_effect_values {{ 
      'daimon_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start'
        },
        'player_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start' 
        }
    }}
    offering_effect_type { 'damage_daimon_and_player' }
    offering_effect_values {{
      'daimon_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start'
        },
        'player_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start' 
        }
    }}
    story_token { false }
    story_sequence { nil }
  end
end
