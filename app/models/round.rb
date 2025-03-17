class Round < ApplicationRecord
  #Associations
  belongs_to :game
  belongs_to :daimon
  has_many :hands

  #Constants
  BASE_DAIMON_HEALTH = 2500
  DAIMON_SCALING_FACTOR = 1.155
  enum :winner, { in_progress: 0, player: 1, daimon: 2 }


  #Callbacks
  before_validation :initialize_round, on: :create
  after_create :start_first_hand

  #Validations
  validates :round_number, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :hand_counter, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :daimon_current_blood_pool, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :daimon_max_blood_pool, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :winner, presence: true

  #Initializers
  def initialize_round
    self.daimon_max_blood_pool = calculate_daimon_health
    self.daimon_current_blood_pool = self.daimon_max_blood_pool

    RoundDeckService.new(self).shuffle_deck #Calls service to shuffle deck
  end

  def start_first_hand
    hands.create!(round: self)
  end

  #Daimon Health for the round
  def calculate_daimon_health
    scaled_health = BASE_DAIMON_HEALTH * (DAIMON_SCALING_FACTOR ** (round_number - 1))

    #Apply Daimon Health Effect Modifiers
    scaled_health *=2 if self.daimon.effect == "double_health"

    scaled_health.to_i
  end
  
  #Calculates the wager for the specific hand
  def calculate_wager
    return 500 if hand_counter < 5
    
    500 + (410 * (hand_counter - 4))
  end

  #Reshuffles if shuffled deck is empty
  def reshuffle_if_empty
    RoundDeckService.new(self).reshuffle_if_empty
  end

  #Updating round attributes
  def update_shuffled_deck(updated_deck)
    self.shuffled_deck = updated_deck
    save!
  end

  def update_daimon_health(amount)
    return if amount.zero?
  
    self.daimon_current_blood_pool += amount
    self.daimon_current_blood_pool = [self.daimon_current_blood_pool, self.daimon_max_blood_pool].min #Prevent overhealing
    self.daimon_current_blood_pool = [self.daimon_current_blood_pool, 0].max #Prevent going below 0
    save!
  end

  def round_over?
    return false unless game.player.blood_pool <= 0 || daimon_current_blood_pool <= 0
  
    update!(winner: game.player.blood_pool <= 0 ? :daimon : :player)
    true
  end  
end
