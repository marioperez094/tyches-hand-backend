class RoundInitializer
  ### Constants
  BASE_DAIMON_HEALTH = 2500
  BASE_PLAYER_HEALTH = 5000
  DAIMON_SCALING_FACTOR = 1.155

  def initialize(game)
    @game = game
    @player = game.player
  end

  def call
    raise 'A round is already active.' if @game&.round&.in_progress?

    initialize_round
  end

  private

  #Prevents creating a new round if its in progress
  def round_in_progress?
    @game.round&.in_progress?
  end

  #Calculates the daimon's max health
  def calculate_daimon_health
    BASE_DAIMON_HEALTH * (DAIMON_SCALING_FACTOR ** (@game.rounds_played))
  end

  #Retrieves the newest daimon available OR randomizes daimon based on player choice
  def set_daimon
    return Daimon.by_unlocked(@player).sample if @game.daimon_progress == @player.story_progression
      
    #If the player has chosen a token the story progression will be greater. This will lead to a new Daimon
    Daimon.next_daimon(@player.story_progression)
  end

  def apply_passive_effects
    ApplyEffectService.apply_token_effects(
      slot: @player.inscribed_slot,
      player: @player,
      round: @game.round,
      phase: 'round_start'
    )

    ApplyEffectService.apply_daimon_effects(
      daimon: @game.round.daimon,
      player: @player,
      round: @game.round,
      phase: 'round_start'
    )
  end
  
  def build_new_round
    daimon = set_daimon
    daimon_blood_pool = calculate_daimon_health

    @game.build_round(
      daimon: daimon,
      daimon_max_blood_pool: daimon_blood_pool,
      daimon_blood_pool: daimon_blood_pool,
      player_max_blood_pool: BASE_PLAYER_HEALTH
    )
  end

  def initialize_round
    new_round = build_new_round
    apply_passive_effects
    new_round
  end
end