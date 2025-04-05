class Deck < ApplicationRecord
  #Associations
  belongs_to :player

  has_many :equipped_cards, dependent: :destroy
  has_many :card_collections, through: :equipped_cards
  has_many :cards, through: :card_collections

  #Callbacks
  before_validation :set_default_name, on: :create

  #Validations
  validates :player, uniqueness: true
  validates :name, presence: true, length: { maximum: 25 }
  validate :validate_player_deck, unless: :new_record? #Skips validation on creation

  def convert_to_collection_ids(card_ids)
    player.card_collections.where(card_id: card_ids)
  end

  private

  def set_default_name
    self.name = "#{ self.player.username }'s Deck" if player.present?
  end

  def validate_player_deck
    return unless player
    
    if player.assigned_cards.size != 52
      errors.add(:base, 'deck must have exactly 52 cards.')
    end

    if player.assigned_cards.uniq.size != player.assigned_cards.size
      errors.add(:base, 'contains duplicate card IDs.')
    end
  end
end
