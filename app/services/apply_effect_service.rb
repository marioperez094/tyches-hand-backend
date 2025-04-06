module ApplyEffectService
  def self.apply_daimon_effects(daimon:, player:, round: nil, hand: nil, phase:)
    return unless player.game.in_progress?
    
    result = EffectTypeModifier.apply(
      effect_type: daimon.effect_type,
      values: daimon.effect_values,
      player: player,
      round: round,
      hand: hand,
      phase: phase
    )
    

    result.each do |step|
      step['source'] = 'daimon'
      step['rune'] = daimon.rune 
    end
  end

  def self.apply_token_effects(slot:, player:, round: nil, hand: nil, phase:)
    return unless player.game.in_progress?
    
    result = EffectTypeModifier.apply(
      effect_type: slot.active_effect_type,
      values: slot.active_effect_values,
      player: player,
      round: round,
      hand: hand,
      phase: phase
    )

    result.each do |step|
      step['source'] = 'token'
      step['rune'] = slot.token.rune
      step['id'] = slot.token.id
    end
  end

  def self.apply_card_effect(card: ,player:, round: nil, hand: nil, phase:)
    return unless player.game.in_progress?

    result = EffectTypeModifier.apply(
      effect_type: card.effect_type,
      values: card.effect_values,
      player: player,
      round: round,
      hand: hand,
      phase: phase
    )

    { card: card, effects: result }
  end
end