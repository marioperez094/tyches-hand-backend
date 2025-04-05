class Token < ApplicationRecord
  include EffectTypes
  
  #Associations
  has_many :token_collections, dependent: :destroy
  has_many :players, through: :token_collections

  #Constants
  SLOT_TYPES = %w[Inscribed Oathbound Offering].freeze

  #Scopes
  scope :story_tokens, -> { where(story_token: true).order(:story_sequence) }
  scope :by_undiscovered, ->(player) { where.not(id: player.tokens.pluck(:id)) }

  #Validations
  validates :name, presence: true, uniqueness: true
  validates :rune, presence: true, uniqueness: true
  validates :description, presence: true
  validates :story_token, inclusion: { in: [true, false] }
  validates :story_sequence, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :story_token?
  validates :story_sequence, absence: true, unless: :story_token?
  validates :inscribed_effect_type, :oathbound_effect_type, :offering_effect_type, presence: true, inclusion: { in: EffectTypes::EFFECT_ACTIONS.keys }
  validates :inscribed_effect_values, effect_values_format: true
  validates :oathbound_effect_values, effect_values_format: true
  validates :offering_effect_values, effect_values_format: true
  
  #Returns next available story token
  def self.next_story_token(current_story_progression)
    find_by(story_sequence: current_story_progression)
  end
end
