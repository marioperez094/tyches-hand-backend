class Card < ApplicationRecord
  #Associations
  has_many :card_collections, dependent: :destroy
  has_many :players, through: :card_collections

  has_many :equipped_cards, dependent: :destroy
  has_many :decks, through: :equipped_cards

  #Callbacks
  before_validation :set_card_name
  before_validation :set_effect_details, if: -> { effect.present? }

  #Constants
  RANKS           = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace].freeze
  SUITS           = %w[Hearts Diamonds Clubs Spades].freeze
  EFFECTS         = %w[Exhumed Charred Fleshwoven Blessed Bloodstained Standard].freeze
  VALID_EFFECT_TYPES = %w[Damage Pot Heal None].freeze

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

  # Validations
  validates :description, presence: true
  validates :suit, inclusion: { in: SUITS }, presence: true
  validates :name, uniqueness: true, presence: true
  validates :rank, presence: true, inclusion: { in: RANKS }
  validates :effect, presence: true, inclusion: { in: EFFECTS } 
  validates :effect_type, presence: true, inclusion: { in: VALID_EFFECT_TYPES }

  def card_numeric_rank
    FACE_CARD_RANK[rank] || rank.to_i
  end

  def calculate_effect_value
    CardEffectCalculator.new(effect, name, card_numeric_rank).calculate_value
  end

  private

  def set_card_name
    self.name = "#{ effect } #{ rank } of #{ suit }"
  end

  def set_effect_details
    calculator = CardEffectCalculator.new(effect, name, card_numeric_rank)
    self.description ||= calculator.description
    self.effect_type ||= calculator.effect_type
    self.effect_description ||= calculator.effect_description
  end
end
