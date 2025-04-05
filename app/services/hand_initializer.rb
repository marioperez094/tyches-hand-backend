class HandInitializer
  def initialize(round)
    @round = round
    @daimon = @round.daimon
    @game = @round.game
    @player = @game.player
    @manager = GameStateManager.new(player: @player)
  end

  def call
    raise 'A hand is already active.' if @round&.hand&.in_progress?

    initialize_hand
  end

  def calculate_wager
    minimum_wager = 500
    return minimum_wager if @round.hands_played < 4

    #Scales from hand 5 to 15
    scaling = [@round.hands_played, 15].min
    
    #Round does not update rounds_played until after creation hence 3
    total_wager = minimum_wager + (scaling - 3) * 409

    player_min_blood_pool = [@player.blood_pool - 1, minimum_wager].max

    [player_min_blood_pool, total_wager].min
  end

  private

  ### Hand Attributes

  #Blood wager
  

  def set_blood_wager
    wager = calculate_wager
    @manager.set_daimon_health(-wager)
    @manager.set_player_health(-wager)
    wager * 2
  end

  ### Apply buffs and debuffs
  def apply_passive_effects
    token_logs = ApplyEffectService.apply_token_effects(
      slot: @player.inscribed_slot,
      player: @player,
      round: @round,
      hand: @round.hand,
      phase: 'hand_start'
    )

    daimon_logs = ApplyEffectService.apply_daimon_effects(
      daimon: @daimon,
      player: @player,
      round: @round,
      hand: @round.hand,
      phase: 'hand_start'
    )

    cards = @round.hand.player_hand_cards
    card_logs = cards.flat_map do |card|
      
      ApplyEffectService.apply_card_effect(
        card: card,
        player: @player,
        round: @round,
        hand: @round.hand,
        phase: 'hand_start'
      )
    end
    [
      { action_type: 'token effects', actions: token_logs },
      { action_type: 'daimon effects', actions: daimon_logs },
      { action_type: 'card effects', action: card_logs }
    ]
  end

  def build_new_hand
    wager = set_blood_wager
    player_hand = @round.shuffled_deck[0..1]               #Player gets two cards
    daimon_hand = @round.shuffled_deck[2..2]               #Daimon has one card but a hidden second card
    @round.shuffled_deck = @round.shuffled_deck[3..] || [] #Altered deck after cards are removed

    @round.build_hand(
      blood_wager: wager,
      player_hand: player_hand,
      daimon_hand: daimon_hand
    )
  end

  def initialize_hand
    new_hand = build_new_hand
    @round.increment!(:hands_played)
    
    apply_passive_effects
    
    manager = GameStateManager.new(player: @player, round: @round, hand: new_hand)
    resolve_if_blackjack(new_hand, manager)
    
    manager.persist_changes(player: @player, round: @round, hand: new_hand) unless new_hand.persisted?
    
    new_hand
  end

  ### Blackjack Resolution
  def resolve_if_blackjack(hand, manager)
    return unless Hand.is_blackjack?(hand.player_hand_cards)

    manager.set_daimon_hand(1)
    result = hand.hand_result?
    hand.hand_resolution(result)
  end
end