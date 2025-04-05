class GameStateManager
  attr_reader :game, :round, :hand, :player 

  def initialize(player:, round: nil, hand: nil)
    @player = player
    @game = player&.game
    @round = round || game&.round
    @hand = hand || round&.hand
  end

  ### Setters
  def set_player_health(amount)
    return unless round
    player_health = player.blood_pool + amount
    player.blood_pool = player_health.clamp(0, round.player_max_blood_pool)

    round.round_over?
  end

  def set_daimon_health(amount)
    return unless round
    daimon_health = round.daimon_blood_pool + amount
    round.daimon_blood_pool = daimon_health.clamp(0, round.daimon_max_blood_pool)

    round.round_over?
  end

  def set_player_max_health(amount)
    return unless round

    new_max = (round.player_max_blood_pool * amount).to_i

    round.player_max_blood_pool = new_max
    player.blood_pool = [player.blood_pool, new_max].min
    
    round.round_over?
  end

  def set_daimon_max_health(amount)
    return unless round

    new_max = (round.daimon_max_blood_pool * amount).to_i

    round.daimon_max_blood_pool = new_max
    round.daimon_blood_pool = [round.daimon_blood_pool, new_max].min
  end

  def set_blood_wager(amount)
    return unless hand

    hand.blood_wager += amount
  end

  def set_shuffled_deck(deck)
    return unless round

    round.shuffled_deck = deck
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