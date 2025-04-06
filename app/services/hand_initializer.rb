class HandInitializer
  def initialize(round)
    @round = round
    @daimon = @round.daimon
    @game = @round.game
    @player = @game.player
    @manager = GameStateManager.new(player: @player)
  end

  #New hand
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
  
  ### Apply buffs and debuffs
  def apply_passive_effects(hand)
    token_logs = ApplyEffectService.apply_token_effects(
      slot: @player.inscribed_slot,
      player: @player,
      round: @round,
      hand: hand,
      phase: 'hand_start'
    )
  
    daimon_logs = ApplyEffectService.apply_daimon_effects(
      daimon: @daimon,
      player: @player,
      round: @round,
      hand: hand,
      phase: 'hand_start'
    )
    
    token_logs + daimon_logs
  end

  def apply_card_effects(hand)
    cards = hand.player_hand_cards
    card_logs = cards.flat_map do |card|
      result = ApplyEffectService.apply_card_effect(
        card: card,
        player: @player,
        round: @round,
        hand: hand,
        phase: 'hand_start'
      )
    end
  end

  def new_hand_compiler(hand)
    hand_setup = [{
      action: 'set_player_health',
      source: 'wager',
      player_blood_pool: @player.blood_pool
    }, {
      action: 'set_daimon_health',
      source: 'wager',
      daimon_blood_pool: @round.daimon_blood_pool
    }, {
      action: 'set_blood_wager',
      source: 'wager',
      blood_wager: hand.blood_wager
    }] 
    
    hand_setup + apply_passive_effects(hand) 
  end

  ### Blackjack Resolution
  def resolve_if_blackjack(hand)
    return unless Hand.is_blackjack?(hand.player_hand_cards)
    
    @manager.set_daimon_hand(1)
    result = hand.hand_result?
    hand.hand_resolution(result)
  end

  private

  ### Hand Attributes

  #Blood wager
  def calculate_wager
    minimum_wager = 500
    return minimum_wager if @round.hands_played < 4

    #Scales from hand 5 to 15
    scaling = [@round.hands_played, 15].min
    
    #Round does not update rounds_played until after creation hence 3
    total_wager = minimum_wager + (scaling - 3) * 409

    player_min_blood_pool = [@player.blood_pool - 1, minimum_wager].max

    [player_min_blood_pool, total_wager].min * 2
  end

  def set_blood_wager
    wager = calculate_wager
    @manager.set_daimon_health(-wager)
    @manager.set_player_health(-wager)
    wager * 2
  end
end