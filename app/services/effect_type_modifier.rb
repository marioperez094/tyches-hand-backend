module EffectTypeModifier
  ### Helpers
  def self.apply(effect_type:, values: {}, player:, round: nil, hand: nil, phase:)
    game = player&.game
    round ||= game&.round
    daimon ||= round&.daimon
    hand ||= round&.hand

    manager = GameStateManager.new(player: player, round: round, hand: hand)

    context = {
      player: player,
      manager: manager,
      game: game,
      round: round, 
      daimon: daimon,
      phase: phase
    }

    actions = EffectTypes.effect_actions(effect_type)
    log_entries = []

    actions.each do |action|
      next unless respond_to?(action)

      action_config = values[action.to_s]
      next unless action_config
      next unless action_config['apply_on_phase'] == phase

      logs = send(action, context.merge(
        action: action, 
        value: action_config['value']
      ))

      log_entries.concat(Array(logs))
    end

    log_entries
  end

  ### Modifier Methods

  #Whether effects should be affected by blood wager or daimon health
  def self.multiplier_source(ctx, player_target)
    round = ctx[:round]
    hand = round&.hand
    value = ctx[:value].to_f

    #If value is less than 1 it is a percentile of daimon/player's total blood pool
    #If value is greater than 1, it is a percentage of the wager
    if value.between?(-1, 1)
      base = player_target ? ctx[:player].max_blood_pool : ctx[:round].daimon_max_blood_pool
    else
      base = (hand&.blood_wager.to_f / 100)
    end
    
    (base * value).to_i || 0
  end

  def self.player_health(ctx)
    amount = multiplier_source(ctx, player_target: true) || 0

    player_health = ctx[:manager].set_player_health(amount)
    [{ effect: ctx[:action].to_s, result: "player_health = #{ player_health }"}]
  end

  def self.daimon_health(ctx)
    return unless ctx[:round]
    amount = multiplier_source(ctx, player_target: false) || 0

    daimon_health = ctx[:manager].set_daimon_health(amount)
    [{ effect: ctx[:action].to_s, result: "daimon_health = #{ daimon_health }"}]
  end
  
  def self.blood_wager(ctx)  
    return unless ctx[:hand]
    amount = multiplier_source(ctx, player_target: false) || 0
    
    blood_wager = ctx[:manager].set_blood_wager(amount)
    [{ effect: ctx[:action].to_s, result: "blood_wager = #{ blood_wager }"}]
  end

  def self.player_max_health(ctx)
    return unless ctx[:round]
  
    multiplier = ctx[:value].to_f
    
    player_max_health = ctx[:manager].set_player_max_health(multiplier)
    [{ effect: ctx[:action].to_s, result: "player_max_health = #{ player_max_health }" }]
  end
  

  def self.daimon_max_health(ctx)
    round = ctx[:round]
    return unless round

    multiplier = ctx[:value].to_f
    daimon_max_health = ctx[:manager].set_daimon_max_health(multiplier)
    [{ effect: ctx[:action].to_s, result: "daimon_max_health = #{ daimon_max_health }"}]
  end

  #Submodifiers

  def self.damage_daimon_with_difference(ctx)
    round = ctx[:round]
    return unless round

    max_health = round.daimon_max_blood_pool
    current_health = round.daimon_blood_pool
    total_damage = max_health - current_health

    multiplier = ctx[:value].to_f
    amount = (total_damage * multiplier).to_i
    
    daimon_health = ctx[:manager].set_daimon_health(amount)
    [{ effect: ctx[:action].to_s, result: "daimon_blood_pool = #{ round.daimon_blood_pool }"}]
  end
end