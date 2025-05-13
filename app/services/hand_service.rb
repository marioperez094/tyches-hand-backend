class HandService
  def initialize(hand)
    raise 'Cannot take actions on a completed hand.' unless hand.in_progress?

    @hand = hand
    @round = hand.round
    @game = hand.round.game
    @player = hand.round.game.player
  end

  def start_hand!
    return if @hand.player_hand.present?

    wager = calculate_wager
    manager = @hand.manager

    manager.adjust_player_health(-wager)
    manager.adjust_daimon_health(-wager)
    manager.set_blood_wager(wager * 2)

    2.times { manager.draw_card(:player) }
    manager.draw_card(:daimon)

    manager.persist!
  end

  ### Player actions
  def player_draws
    # Reshuffles cards if deck is empty on drawing
    reshuffle_if_needed

    new_card = @hand.manager.set_player_hand(1)
    new_card_data = Hand.full_cards(new_card)
    @hand.player_hand_cards(force: true)

    apply_card_effects(new_card_data)
  end

  def apply_card_effects(cards)
    card_logs = cards.flat_map do |card|
      result = ApplyEffectService.apply_card_effect(
        card: card,
        player: @player,
        round: @round,
        hand: @hand,
        phase: 'hand_start'
      )
    end
  end

  def daimon_draws
    drawn_cards = []

    while Hand.hand_total(@hand.daimon_hand_cards(force: true)) < 17
      reshuffle_if_needed

      drawn_card_id = @hand.manager.set_daimon_hand(1)
      drawn_cards << drawn_card_id.first
    end

    @hand.daimon_hand_cards(force:true)
    
    Hand.full_cards(drawn_cards)
  end

  def available_player_actions
    return unless @hand.in_progress?

    unless @player.tutorial_finished
      return tutorial_available_actions
    end

    actions = []

    actions << :hit unless player_hand_bust?
    actions << :stand unless player_hand_bust?
    actions << :double_down if can_double_down?
    actions << :surrender if can_surrender?

    actions
  end

  private

  def calculate_wager
    minimum_wager = 500
    return minimum_wager if @round.hands_played < 4

    #Scales from hand 5 to 15
    scaling = [@round.hands_played, 15].min
    
    #Round does not update rounds_played until after creation hence 3
    total_wager = minimum_wager + (scaling - 4) * 409

    player_min_blood_pool = [@player.blood_pool - 1, minimum_wager].max

    [player_min_blood_pool, total_wager].min
  end

  #Limits player actions only during the tutorial
  def tutorial_available_actions
    case @round.shuffled_deck.size
    when 49 then [:hit]
    when 48 then [:stand]
    when 44 then [:stand]
    when 39 then [:surrender]
    when 36 then [:double_down]
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