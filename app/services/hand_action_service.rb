class HandActionService
  def initialize(hand)
    raise 'Cannot take actions on a completed hand.' unless hand.in_progress?

    @hand = hand
    @round = hand.round
    @game = hand.round.game
    @player = hand.round.game.player
  end

  ### Player actions
  def player_draws
    # Reshuffles cards if deck is empty on drawing
    reshuffle_if_needed

    new_card = @hand.manager.set_player_hand(1)
    new_card_data = Hand.full_cards(new_card).first
    @hand.player_hand_cards(force: true)
    
    ApplyEffectService.apply_card_effect(
      card: new_card_data,
      player: @player,
      round: @round,
      hand: @hand,
      phase: 'hand_start'
    )
  end

  def player_stands
    drawn_cards = []

    while Hand.hand_total(@hand.daimon_hand_cards(force: true)) < 17
      reshuffle_if_needed

      drawn_card_id = @hand.manager.set_daimon_hand(1)
      drawn_cards << drawn_card_id
    end

    drawn_cards
  end

  ### Hand Method Helpers
  def player_hand_bust?
    Hand.hand_total(@hand.player_hand_cards) > 21
  end

  def available_player_actions
    return unless @hand.in_progress?

    unless @player.tutorial_finished
      return tutorial_available_actions
    end

    actions = []

    actions << :draw unless player_hand_bust?
    actions << :stand unless player_hand_bust?
    actions << :double_down if can_double_down?
    actions << :surrender if can_surrender? 
  end

  private

  #Limits player actions only during the tutorial
  def tutorial_available_actions
    case @round.shuffled_deck.size
    when 49 then [:draw]
    when 48 then [:stand]
    when 44 then [:stand]
    when 39 then [:surrender]
    when 34 then [:double_down]
    else []
    end
  end

  def can_double_down?
    @hand.player_hand_cards.size == 2 
  end

  def can_surrender?
    @hand.player_hand_cards.size == 2 
  end

  def reshuffle_if_needed
    @round.reshuffle_if_empty if @round.shuffled_deck.empty?
  end
end