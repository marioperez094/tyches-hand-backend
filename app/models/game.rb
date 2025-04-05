class Game < ApplicationRecord
  ### Associations
  belongs_to :player
  has_one :round, dependent: :destroy

  ### Constants
  enum :status, { in_progress: 0, lost: 1 }

  ### Validations
  
  #Round stats
  validates :daimon_progress, presence: true, numericality: { greater_than_or_equal_to: -1 }
  validates :status, presence: true, inclusion: { in: statuses.keys }

  #Game stats
  validates :rounds_played, :total_hands_won, :total_hands_lost, :win_streak, :longest_win_streak, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :longest_win_streak_must_be_greater_or_equal

  ### Initial round setups

  #Increases story daimon progress if the player picks a lore token
  def advance_daimon
    increment!(:daimon_progress) if player.story_progression > daimon_progress
  end

  #Updates player and game stats
  def update_round_stats
    increment!(:rounds_played)
    player.increment!(:games_played)
  end

  ### Hand stats

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

  def game_lost
    update!(status: :lost)
  end
  
  private

  def longest_win_streak_must_be_greater_or_equal
    return unless longest_win_streak && win_streak

    if longest_win_streak < win_streak
      errors.add(:longest_win_streak, 'must be greater than or equal to win_streak')
    end
  end
end
