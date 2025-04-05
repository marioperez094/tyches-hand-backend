class Daimon < ApplicationRecord
  include EffectTypes
  
  has_many :rounds, dependent: :destroy

  #Scopes
  scope :by_unlocked, ->(player) { where("story_sequence <= ?", player.story_progression) }

  #Validations
  validates :name, presence: true, uniqueness: true
  validates :rune, uniqueness: true
  validates :description, presence: true
  validates :effect_type, presence: true, uniqueness: true, inclusion: { in: EffectTypes::EFFECT_ACTIONS.keys }
  validates :intro, :player_win, :player_lose, :dialogue, presence: true
  validates :story_sequence, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :effect_values, effect_values_format: true
  
  #Retrieves the next Daimon based on the player's lore progression
  def self.next_daimon(player_story_progression)
    find_by(story_sequence: player_story_progression)
  end

  #Returns a daimon dialogue line from the JSON array
  def daimon_dialogue
    dialogue.sample || "..."
  end
end
