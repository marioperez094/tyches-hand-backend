class GameStateManager
  attr_reader :game, :round, :hand, :player 

  def initialize(player:, round: nil, hand: nil)
    @player = player
    @game = player&.game
    @round = round || game&.round
    @hand = hand || round&.hand

    @player_changes = {}
    @round_changes = {}
    @hand_changes = {}
  end

  ### Setters
  def adjust_player_health(amount)
    return unless round
    player_health = player.blood_pool + amount
    clamped = player_health.clamp(0, round.player_max_blood_pool)
    @player_changes[:blood_pool] = clamped
  end

  def set_daimon_health(amount)
    return unless round
    daimon_health = round.daimon_blood_pool + amount
    clamped = daimon_health.clamp(0, round.daimon_max_blood_pool)
    @round_changes[:daimon_blood_pool] = clamped
  end

  def set_player_max_health(amount)
    return unless round
    current = (round.player_max_blood_pool + amount).to_i
    @round_changes[:player_max_blood_pool] = current
    @player_changes[:blood_pool] = [player.blood_pool, current].min
  end

  def set_daimon_max_health(amount)
    return unless round
    current = (round.daimon_max_blood_pool * amount).to_i
    @round_changes[:daimon_max_blood_pool] = current
    @round_changes[:daimon_blood_pool] = [round.daimon_blood_pool, current].min
  end

  def set_blood_wager(amount)
    return unless hand
    current = hand.blood_wager + amount
    @hand_changes[:blood_wager] = current
  end

  def set_shuffled_deck(deck)
    return unless round

    round.shuffled_deck = deck
  end

  def draw_card(target)
    return unless hand

    card = round.shuffled_deck[0..0]
    
  end

  def set_player_hand(amount)
    return unless hand
    card_index = amount - 1
    
    new_cards = round.shuffled_deck[0..card_index]
    hand.player_hand += round.shuffled_deck[0..card_index]
    round.shuffled_deck = round.shuffled_deck[amount..] || []

    new_cards
  end

  def set_daimon_hand(amount)
    return unless hand 
    card_index = amount - 1

    new_cards = round.shuffled_deck[0..card_index]
    hand.daimon_hand += new_cards
    round.shuffled_deck = round.shuffled_deck[amount..] || []

    new_cards
  end

  ### Persist method

  def persist_changes(player:, round: nil, hand: nil)
    player.save! if player&.changed?
    round.save! if round&.changed?
    hand.save! if hand&.changed?
  end
end