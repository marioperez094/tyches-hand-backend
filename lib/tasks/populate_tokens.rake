#heroku run rake tokens:populate_tokens
namespace :tokens do
  desc "Populate tokens"
  task populate_tokens: :environment do
    tokens = [{
      name: 'Red Tearstone Token',
      rune: 'Θ',
      description: 'Tyche rewards those who dare play the odds - for a great wager deserves a great reward. But be certain you can withstand the cost.',
      inscribed_effect_type: 'damage_daimon_limit_health',
      inscribed_effect_values: {
        'damage_daimon_with_difference' => {
          'value' => -0.15,
          'apply_on_phase' => 'hand_start'
        },
        'player_max_health' => {
          'value' => 0.2,
          'apply_on_phase' => 'round_start'
        }
      },
      oathbound_effect_type: 'damage_daimon_and_player',
      oathbound_effect_values: {
        'daimon_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start'
        },
        'player_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start' 
        }
      },
      offering_effect_type: 'damage_daimon_and_player',
      offering_effect_values: {
        'daimon_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start'
        },
        'player_health_on_hand' => {
          'value' => 0.3,
          'apply_on_phase' => 'hand_start' 
        }
      },
      story_token: false,
    }]

    tokens.each do |token_data|
      Token.find_or_create_by!(name: token_data[:name]) do |token|
        token.rune = token_data[:rune]
        token.description = token_data[:description]
        token.inscribed_effect_type = token_data[:inscribed_effect_type]
        token.inscribed_effect_values = token_data[:inscribed_effect_values]
        token.oathbound_effect_type = token_data[:oathbound_effect_type]
        token.oathbound_effect_values = token_data[:oathbound_effect_values]
        token.offering_effect_type = token_data[:offering_effect_type]
        token.offering_effect_values = token_data[:offering_effect_values]
        token.story_token = token_data[:story_token]
        token.story_sequence = token_data[:story_sequence]
      end
    end

    puts "Tokens populated successfully!"
  end
end