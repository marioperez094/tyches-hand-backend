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

    [{ step: 'apply_daimon_effect', effect: daimon.effect_type, result: result }]
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

    [{ step: 'apply_token_effect', effect: slot.active_effect_type, result: result }]
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

    [{ step: 'apply_card_effect', effect: card.effect_type, card: card, result: result }]
  end
end