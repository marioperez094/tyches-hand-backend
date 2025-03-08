class Token < ApplicationRecord
  #Associations
  has_many :token_collections, dependent: :destroy
  has_many :players, through: :token_collections

  #Constants
  EFFECT_TYPES = %w[Damage Pot Heal Utility Misc].freeze
  SLOT_TYPES = %w[Inscribed Oathbound Offering].freeze

  #Scopes
  scope :lore_tokens, -> { where(lore_token: true).order(:sequence_order) }
  scope :by_effect_type, ->(type) { where(effect_type: type) }
  #scope :by_undiscovered, ->(player) { where.not(id: player.tokens.pluck(:id)) }

  #Validations
  validates :name, presence: true, uniqueness: true
  validates :rune, presence: true, uniqueness: true
  validates :description, presence: true
  validates :effect_type, presence: true, inclusion: { in: EFFECT_TYPES }
  validates :lore_token, inclusion: { in: [true, false] }
  validates :sequence_order, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :lore_token?
  validates :sequence_order, absence: true, unless: :lore_token?
  validates :inscribed_effect, :oathbound_effect, :offering_effect, presence: true

  #Returns next available lore token
  def self.next_lore_token(current_lore_progression)
    lore_tokens.offset(current_lore_progression).first
  end
end
