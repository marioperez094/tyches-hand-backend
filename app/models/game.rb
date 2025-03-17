class Game < ApplicationRecord
  #Associations
  belongs_to :player
  has_many :rounds

  #Callbacks
  after_create :start_first_round

  #Constants
  enum :status, { in_progress: 0, lost: 1 }

  #Validations
  validates :story_daimon_progress, presence: true, numericality: { greater_than_or_equal_to: -1 }
  validates :current_round, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :status, presence: true
  validates :status_before_type_cast, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validates :total_hands_won, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_hands_lost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :win_streak, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :longest_win_streak, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :longest_win_streak_must_be_greater_or_equal

  def start_first_round
    rounds.create!(game: self, daimon: set_daimon)
  end

  def set_daimon
    if self.story_daimon_progress == player.lore_progression
      return Daimon.by_unlocked(player).sample
    end
    
    advance_daimon
    Daimon.next_daimon(player.lore_progression)
  end
  

  #Increases story daimon progress if the player picks a lore token
  def advance_daimon
    if player.lore_progression > story_daimon_progress
      self.story_daimon_progress = player.lore_progression
    end
    save!
  end

   #Increments player hand wins and updates win streak
   def record_hand_win
    increment!(:total_hands_won)
    increment!(:win_streak)
    self.longest_win_streak = [win_streak, longest_win_streak].max
    save!
  end

  #Increments player hand losses and resets win streak
  def record_hand_loss
    increment!(:total_hands_lost)
    self.win_streak = 0
    save!
  end

  private

  def longest_win_streak_must_be_greater_or_equal
    if longest_win_streak < win_streak
      errors.add(:longest_win_streak, 'must be greater than or equal to win_streak')
    end
  end
end
