module CardEffectCalculator
  EFFECT_DETAILS = {
    "Blessed" => {
      value_calculation: ->(rank) { (20 * rank / 15.0).round(2) },
      description: 'The cards are blinding, and sizzles to the touch.',
      discovery_probability: ->(health_odds) { 0.5 * (1.5 - health_odds) },
      effect_type: 'loss_blood_return',
      apply_on_phase: 'on_loss'

    },
    "Bloodstained" => {
      value_calculation: ->(rank) { (-25 * rank / 15.0).round(2) },
      description: 'The cards are matted together by blood, filling the room with their foul odor.',
      discovery_probability: ->(health_odds) { 0.2 * (1 - health_odds) },
      effect_type: 'damage_daimon',
      apply_on_phase: 'hand_start'
    },
    "Charred" => {
      value_calculation: ->(rank) { (10 * rank / 15.0).round(2) },
      description: 'The embers on these cards can still cauterize wounds.',
      discovery_probability: ->(health_odds) { (0.6 + health_odds) / 2 },
      effect_type: 'heal_player',
      apply_on_phase: 'hand_start'
    },
    "Exhumed" => {
      value_calculation: ->(rank) { (25 * rank / 15.0).round },
      description: "Cards ripped from a corpse's stiff grip.",
      discovery_probability: ->(health_odds) { (0.4 + health_odds) / 1.4 },
      effect_type: 'increase_pot_on_win',
      apply_on_phase: 'on_win'
    },
    "Fleshwoven" => {
      value_calculation: ->(rank) { (50  * rank / 15.0).round(2) },
      description: 'These cards appear to have a leathery texture and an odd familiarity.' ,
      discovery_probability: ->(health_odds) { 0.6 },
      effect_type: 'push_blood_return',
      apply_on_phase: 'on_push'
    }
  }.freeze

  def self.effect_values(effect, rank)
    effect_type = effect_type(effect)
    actions = EffectTypes.effect_actions(effect_type)
    value = EFFECT_DETAILS.dig(effect, :value_calculation)&.call(rank)
    apply_on_phase = EFFECT_DETAILS.dig(effect, :apply_on_phase)

    return {} unless actions && value && apply_on_phase
    
    actions.index_with do 
      { 'value' => value, 
        'apply_on_phase' => apply_on_phase 
      }
    end.transform_keys(&:to_s)
  end
  
  def self.description(effect)
    EFFECT_DETAILS.dig(effect, :description) || 
      "A standard deck of cards, they are almost boring with how ordinary they appear."
  end

  def self.effect_type(effect)
    EFFECT_DETAILS.dig(effect, :effect_type) || "none"
  end
end