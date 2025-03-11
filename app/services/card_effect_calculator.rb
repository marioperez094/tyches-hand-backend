class CardEffectCalculator
  EFFECT_DETAILS = {
    "Exhumed" => {
      value_calculation: ->(rank) { (1 + 0.5 * rank / 15.0).round },
      description: "Cards ripped from a corpse's stiff grip.",
      discovery_probability: ->(health_odds) { (0.4 + health_odds) / 1.4 },
      effect_type: 'Pot',
      effect_description: 'Increases blood pot payout on a win.'
    },
    "Charred" => {
      value_calculation: ->(rank) { (0.2 * (rank / 15.0)).round(2) },
      description: 'The embers on these cards can still cauterize wounds.',
      discovery_probability: ->(health_odds) { (0.6 + health_odds) / 2 },
      effect_type: 'Heal',
      effect_description: 'Partially refunds blood lost on wager.'
    },
    "Fleshwoven" => {
      value_calculation: ->(rank) { (1 + rank / 15.0).round(2) },
      description: 'These cards appear to have a leathery texture and an odd familiarity.' ,
      discovery_probability: ->(health_odds) { 0.6 },
      effect_type: 'Pot',
      effect_description: 'Increases blood pot payout on a push.'
    },
    "Blessed" => {
      value_calculation: ->(rank) { (0.4 * rank / 15.0).round(2) },
      description: 'The cards are blinding, and sizzles to the touch.',
      discovery_probability: ->(health_odds) { 0.5 * (1.5 - health_odds) },
      effect_type: 'Pot',
      effect_description: 'Partially refunds blood lost on a loss.'
    },
    "Bloodstained" => {
      value_calculation: ->(rank) { (1 + 0.1 * (rank / 15.0)).round(2) },
      description: 'The cards are matted together by blood, filling the room with their foul odor.',
      discovery_probability: ->(health_odds) { 0.2 * (1 - health_odds) },
      effect_type: 'Damage',
      effect_description: 'House takes extra damage.'
    }
  }.freeze

  def initialize(effect, card_name, card_rank)
    @effect = effect
    @card_name = card_name
    @card_rank = card_rank
  end

  def calculate_value
    EFFECT_DETAILS.dig(@effect, :value_calculation)&.call(@card_rank)
  end
  
  def description
    EFFECT_DETAILS.dig(@effect, :description) || "A standard deck of cards, they are almost boring with how ordinary they appear."
  end

  def effect_type
    EFFECT_DETAILS.dig(@effect, :effect_type) || "None"
  end

  def effect_description
    EFFECT_DETAILS.dig(@effect, :effect_description) || "No effect."
  end
end