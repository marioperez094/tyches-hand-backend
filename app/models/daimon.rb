class Daimon < ApplicationRecord
  #Scopes
  scope :by_unlocked, ->(player) { where("progression_level <= ?", player.lore_progression) }

  #Constants
  EFFECT_TYPES = %w[Damage Pot Heal Misc None].freeze

  #Validations
  validates :name, presence: true, uniqueness: true
  validates :rune, presence: true, uniqueness: true
  validates :effect, presence: true, uniqueness: true
  validates :effect_type, presence: true, inclusion: { in: EFFECT_TYPES }
  validates :intro, :player_win, :player_lose, presence: true
  validates :progression_level, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  #Retrieves the next Daimon based on the player's lore progression
  def self.next_daimon(current_lore_progression)
    find_by(progression_level: current_lore_progression)
  end

  #Returns a random taunt from the JSON array
  def random_taunt
    taunts.sample || "..."
  end
end
