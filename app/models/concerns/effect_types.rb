module EffectTypes
  EFFECT_ACTIONS = {
    'heal_player' => {
      actions: [:player_health],
      description: "The gambler's blood pool is replenished."
    },
    'damage_player' => {
      actions: [:player_health],
      description: 'The gambler takes extra damage.'
    },
    'increase_max_health' => {
      actions: [:player_max_health],
      description: "Increases the gambler's maximum blood pool capacity."
    },
    'decrease_max_health' => {
      actions: [:player_max_health],
      description: "Decreases the gambler's maximum blood pool capacity."
    },
    'heal_daimon' => {
      actions: [:daimon_health],
      description: "The house's blood pool is replenished."
    },
    'damage_daimon' => { 
      actions: [:daimon_health],
      description: 'The house takes extra damage.'
    }, 
    'increase_daimon_max_health' => {
      actions: [:daimon_max_health],
      description: "Increases the house's maximum blood pool capacity"
    },
    'decrease_daimon_max_health' => {
      actions: [:daimon_max_health],
      description: "Decreases the house's maximum blood pool capacity"
    },
    'increase_pot_on_win' => {
      actions: [:blood_pot],
      description: 'Increases blood pot payout on a win.'
    },
    'push_blood_return' => {
      actions: [:player_health],
      description: 'Increases blood pot returned on a push.'
    },
    'loss_blood_return' => {
      actions: [:player_health],
      description: 'Partially refunds blood lost on a loss.'
    },
    'show_card_count' => {
      actions: [:show_card_count],
      description: 'Shows the current card count.'
    },
    'show_next_card_count' => {
      actions: [:show_next_card_count],
      description: 'Shows whether the next card will increase or decrease the card count.'
    },
    'show_next_card' => {
      actions: [:show_next_card],
      description: 'Shows the next card.'
    }, 
    'damage_daimon_limit_health' => {
      actions: [:damage_daimon_with_difference, :player_max_health],
      description: "The house takes extra damage by limiting the gambler's blood pool."
    },
    'damage_daimon_and_player' => {
      actions: [:daimon_health, :player_health],
      description: "The house and the gambler take extra damage."
    },
    'none' => {
      actions: [:none],
      description: "No effect."
    }
  }.freeze

  def self.effect_actions(effect_type)
    effect_actions = EFFECT_ACTIONS[effect_type]&.dig(:actions) || []
  end
end
