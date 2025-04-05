class Card < ApplicationRecord
  include EffectTypes

  #Associations
  has_many :card_collections, dependent: :destroy
  has_many :players, through: :card_collections

  #Callbacks
  before_validation :set_card_name
  before_validation :set_effect_details, if: -> { effect.present? }
  validates :effect_values, effect_values_format: true

  #Constants
  RANKS           = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace].freeze
  SUITS           = %w[Clubs Diamonds Hearts Spades].freeze
  EFFECTS         = %w[Blessed Bloodstained Charred Exhumed Fleshwoven Standard].freeze

  #Numerical rank for calculating effect 
  FACE_CARD_RANK = {
    'Jack'  => 11,
    'Queen' => 12,
    'King'  => 13,
    'Ace'   => 15
  }.freeze 

  #Scopes
  scope :by_suit, ->(suit) { where(suit: suit) }
  scope :by_effect, ->(type) { where(effect: type) }
  scope :by_effect_type, ->(type) { where(effect_type: type) }
  scope :by_undiscovered, ->(player) { where.not(id: player.cards.pluck(:id)) }

  #Validations
  validates :name, presence: true, uniqueness: true
  validates :suit, presence: true, inclusion: { in: SUITS }
  validates :rank, presence: true, inclusion: { in: RANKS }
  validates :description, presence: true
  validates :effect, presence: true, inclusion: { in: EFFECTS } 
  validates :effect_type, presence: true, inclusion: { in: EffectTypes::EFFECT_ACTIONS.keys }

  def card_numeric_rank
    FACE_CARD_RANK[rank] || rank.to_i
  end

  private

  def set_card_name
    self.name = "#{ effect } #{ rank } of #{ suit }"
  end

  def set_effect_details
    self.description ||= CardEffectCalculator.description(effect)
    self.effect_type ||= CardEffectCalculator.effect_type(effect)
    self.effect_values ||= CardEffectCalculator.effect_values(effect, card_numeric_rank)
  end
end
