class Hand < ApplicationRecord
  #Associations
  belongs_to :round

  #Constants
  enum :status, { in_progress: 0, won: 1, lost: 2, pushed: 3 }

  #Validations
  validates :blood_wager, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :status, presence: true, inclusion: { in: statuses.keys }

  #def player_doubles_down
    #player_hand = player_draw
    #deduct_wager = @hand.blood_wager / 2

    #manager.set_player_health(-deduct_wager)
    #manager.set_daimon_health(-deduct_wager)
    #manager.set_blood_wager(blood_wager)

    #Player actions stop after doubling down 
    #player_stand

    #Returns result from drawing a new hand
    #player_hand
  #end

  ### Cards
  def player_hand_cards(force: false)
    @player_hand_cards = nil if force
    @player_hand_cards ||= Hand.full_cards(player_hand)
  end
  
  def daimon_hand_cards(force: false)
    @daimon_hand_cards = nil if force
    @daimon_hand_cards ||= Hand.full_cards(daimon_hand)
  end

  #Hand Complete
  def hand_result?
    player_total = Hand.hand_total(player_hand_cards)
    daimon_total = Hand.hand_total(daimon_hand_cards)

    player_blackjack = Hand.is_blackjack?(player_hand_cards)
    daimon_blackjack = Hand.is_blackjack?(daimon_hand_cards)

    winner = case 
                  when player_blackjack && daimon_blackjack then :pushed
                  when player_blackjack then :won
                  when daimon_blackjack then :lost
                  when daimon_total > 21 then :won
                  when daimon_total > player_total then :lost
                  when daimon_total < player_total then :won
                  else :pushed
                  end
  end
  
  def hand_resolution(hand_result)
    case hand_result
    when :won
      manager.set_player_health(blood_wager)
      puts "#{ round.game.player.blood_pool }"
      round.game.record_hand_win
    when :lost
      manager.set_daimon_health(blood_wager)
      round.game.record_hand_loss
    when :pushed
      refund_amount = (blood_wager || 0) / 2
      manager.set_player_health(refund_amount)
      manager.set_daimon_health(refund_amount)
      round.game.record_hand_loss
    end
    
    self.status = hand_result
    discard_both_hands
    manager_persist_changes
  end

  #Helper methods 
  def self.hand_total(cards)
    face_card_values = { 'Jack' => 10, 'King' => 10, 'Queen' => 10 }

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

  def self.is_blackjack?(cards)
    Hand.hand_total(cards) == 21 && cards.count == 2
  end

  #Converts IDs to Card objects
  def self.full_cards(card_ids)
    Card.find(card_ids)
  end

  private 
  
  ### Game Manager
  def manager
    GameStateManager.new(player: round.game.player, round: round, hand: self)
  end

  def manager_persist_changes
      manager.persist_changes(player: round.game.player, round: round, hand: self)
  end

  def discard_both_hands
    round.discard_pile += player_hand
    round.discard_pile += daimon_hand
  end  
end
