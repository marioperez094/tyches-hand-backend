class Hand < ApplicationRecord
  #Associations
  belongs_to :round

  #Constants
  enum :winner, { in_progress: 0, player: 1, daimon: 2, push: 3 }

  #Callbacks
  before_validation :initialize_hand, on: :create

  #Validations
  validates :hand_number, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :winner, presence: true

  #Initializer
  def initialize_hand
    self.player_hand = round.shuffled_deck[0..1] #Player gets two cards
    self.daimon_hand = round.shuffled_deck[2..2] #Daimon has one card but a hidden second card

    new_deck = round.shuffled_deck[3..] || [] #Altered deck after cards are removed.

    round.update_shuffled_deck(new_deck)

    set_blood_wager
  end

  #Calculates the blood_wager
  def set_blood_wager
    wager = round.calculate_wager

    round.game.player.update_player_health(-wager)
    round.update_daimon_health(-wager)

    self.blood_wager = wager * 2
  end

  #Basic player actions
  def draw_player_card
    round.reshuffle_if_empty if round.shuffled_deck.empty?  #Reshuffles cards if deck is empty

    drawn_card_id = round.shuffled_deck.first
    new_deck = round.shuffled_deck[1..] || []
    
    self.player_hand << drawn_card_id
    save!
    
    round.update_shuffled_deck(new_deck)

    Card.find(drawn_card_id)
  end

  def player_stand
    drawn_cards = []

    while hand_total(self.daimon_hand) < 17
      round.reshuffle_if_empty if round.shuffled_deck.empty? 

      drawn_card_id = round.shuffled_deck.shift
      drawn_cards << drawn_card_id
      self.daimon_hand << drawn_card_id
    end

    save!
    round.update_shuffled_deck(round.shuffled_deck)

    drawn_cards.any? ? full_cards(drawn_cards) : []
  end

  #Hand Complete
  def hand_resolution(outcome)
    case outcome
    when :player
      round.game.player.update_player_health(blood_wager)
      round.game.record_hand_win
    when :daimon
      round.update_daimon_health(blood_wager)
      round.game.record_hand_loss
    when :push
      refund_amount = blood_wager / 2
      round.game.player.update_player_health(refund_amount)
      round.update_daimon_health(refund_amount)
      round.game.record_hand_loss
    end

    update!(winner: outcome)
  end

  #Helper methods 
  def hand_total(card_ids)
    face_card_values = { 'Jack' => 10, 'King' => 10, 'Queen' => 10 }
    cards = Card.where(id: card_ids)
  
    sum = 0
    aces = 0
  
    #Process all non-Ace cards first
    cards.each do |card|
      if card.rank == 'Ace'
        aces += 1
      else
        sum += face_card_values[card.rank] || card.rank.to_i
      end
    end
    
    #Now handle Aces AFTER all cards have been counted
    sum += aces
    if aces > 0 && sum + 10 <= 21
      sum += 10
    end
    
    sum
  end

  def hand_result?
    player_total = hand_total(self.player_hand)
    daimon_total = hand_total(self.daimon_hand)
    
    return :player if daimon_total > 21
    return :daimon if daimon_total > player_total
    return :player if daimon_total < player_total
    :push
  end

  def player_hand_bust?
    hand_total(self.player_hand) > 21
  end

  #Converts IDs to Card objects
  def full_cards(card_ids)
    Card.find(card_ids)
  end
end
