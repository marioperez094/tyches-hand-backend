class Round < ApplicationRecord
  #Associations
  belongs_to :game
  belongs_to :daimon
  has_one :hand, dependent: :destroy

  ### Constants
  enum :status, { in_progress: 0, won: 1, lost: 2 }

  ### Callbacks
  before_validation :generate_shuffled_deck, on: :create

  ### Validations
  validates :card_count, :hands_played, :daimon_blood_pool, :daimon_max_blood_pool, :player_max_blood_pool, 
    presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: statuses.keys }

  validate :validate_shuffled_deck
  
  #Game Manager
  def manager
    GameStateManager.new(player: game.player, round: self, hand: self&.hand)
  end

  def manager_persist_changes
      manager.persist_changes(player: game.player, round: self, hand: self&.hand)
  end

  #Reshuffles if shuffled deck is empty
  def reshuffle_if_empty
    return shuffled_deck unless shuffled_deck.empty?
    self.shuffled_deck =  generate_shuffled_deck
    self.discard_pile = []
    save!
  end

  def round_over?
    return false unless game.player.blood_pool <= 0 || daimon_blood_pool <= 0
  
    update!(status: game.player.blood_pool <= 0 ? :lost : :won)
    game.game_lost if self.lost?
    true
  end

  private 

  def validate_shuffled_deck
    return if shuffled_deck.blank?

    if shuffled_deck.uniq.size != shuffled_deck.size
      errors.add(:shuffled_deck, 'contains duplicate card IDs.')
    end
  end

  def generate_shuffled_deck
    return shuffled_deck unless shuffled_deck.empty?
    player = game.player

    return self.shuffled_deck = RoundDeckService.tutorial_deck unless player.tutorial_finished
    
    cards = discard_pile.present? ? Card.where(id: discard_pile) : player.assigned_cards
    weights = RoundDeckService.rank_bias_by_round(cards: cards, rounds: game.rounds_played)
    shuffled_cards = RoundDeckService.shuffle_deck(cards: cards, custom_weights: weights)

    self.shuffled_deck =  shuffled_cards

    shuffled_cards || []
  end

  def discard_both_hands
    round.discard_pile += player_hand
    round.discard_pile += daimon_hand
  end
end
