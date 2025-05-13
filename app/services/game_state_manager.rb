class GameStateManager
  attr_reader :game, :round, :hand, :player 

  def initialize(player:, round: nil, hand: nil)
    @player = player
    @game = player&.game
    @round = round || game&.round
    @hand = hand || round&.hand

    initialize_changes
  end

  ### Setters
  def adjust_player_health(amount)
    return unless round
    player_health = @player_changes[:blood_pool] += amount
    @player_changes[:blood_pool] = clamp_health(player_health, round.player_max_blood_pool)
  end

  def adjust_daimon_health(amount)
    return unless round
    daimon_health = @round_changes[:daimon_blood_pool] + amount
    @round_changes[:daimon_blood_pool] = clamp_health(daimon_health, round.daimon_max_blood_pool)
  end

  def set_player_max_health(amount)
    return unless round
    current = (@round_changes[:player_max_blood_pool] * amount).to_i
    @round_changes[:player_max_blood_pool] = current
    @player_changes[:blood_pool] = [player.blood_pool, current].min
  end

  def set_daimon_max_health(amount)
    return unless round
    current = (@round_changes[:daimon_max_blood_pool] * amount).to_i
    @round_changes[:daimon_max_blood_pool] = current
    @round_changes[:daimon_blood_pool] = [round.daimon_blood_pool, current].min
  end

  def set_blood_wager(amount)
    return unless hand
    current = @hand_changes[:blood_wager] + amount
    @hand_changes[:blood_wager] = current
  end

  def draw_card(target)
    return unless hand

    reshuffle_if_needed

    deck = @round_changes[:shuffled_deck]
    
    card_id = deck.shift
    @round_changes[:shuffled_deck] = deck

    case target
    when :player
      @hand_changes[:player_hand] << card_id
    when :daimon
      @hand_changes[:daimon_hand] << card_id
    end

    card_id
  end

  def discard_cards
    return unless hand

    discard = @round_changes[:discard_pile.dup]
    player_hand =  @hand_changes[:player_hand]
    daimon_hand = @hand_changes[:daimon_hand]
    
    discard.concat(player_hand)
    discard.concat(daimon_hand)

    @round_changes[:discard_pile] = discard
    @hand_changes[:player_hand] = []
    @hand_changes[:daimon_hand] = []
  end

  ### Persist method

  def persist!
    ActiveRecord::Base.transaction do
      player.assign_attributes(@player_changes)
      player.save! if (player.changed?)
      game.save! if game&.changed?

      return unless round
      round.assign_attributes(@round_changes)
      round.save! if (round.new_record? || round.changed?)

      return unless hand
      hand.assign_attributes(@hand_changes)
      hand.save! if (hand.new_record? || hand.changed?)
    end
  end

  private 

  #Duplicates DB for easy mutations
  def initialize_changes 
    @player_changes = {
      blood_pool: player.blood_pool
    }
    @round_changes = {
      card_count: round&.card_count,
      shuffled_deck: round&.shuffled_deck&.dup || [],
      discard_pile: round&.discard_pile&.dup || [], 
      player_max_blood_pool: round&.player_max_blood_pool,
      daimon_max_blood_pool: round&.daimon_max_blood_pool,
      daimon_blood_pool: round&.daimon_blood_pool
    }
    
    @hand_changes = {
      blood_wager: hand&.blood_wager,
      player_hand: hand&.player_hand&.dup || [],
      daimon_hand: hand&.daimon_hand&.dup || []
    }
  end  

  def clamp_health(value, max_health)
    value.clamp(0, max_health)
  end

  def reshuffle_if_needed
    round.reshuffle_if_empty if round.shuffled_deck.empty?
    @round_changes[:shuffled_deck] = round.shuffled_deck
  end
end