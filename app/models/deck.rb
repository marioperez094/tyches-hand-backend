class Deck < ApplicationRecord
  #Associations
  belongs_to :player

  has_many :equipped_cards, dependent: :destroy
  has_many :cards, through: :equipped_cards

  #Callbacks
  before_validation :set_default_name, on: :create

  #Validations
  validates :player, uniqueness: true
  validates :name, presence: true, length: { maximum: 25 }
  validate :ensure_deck_size, unless: :new_record? #Skips validation on creation

  private

  def set_default_name
    self.name = "#{ self.player.username }'s Deck" if player.present?
  end

  def ensure_deck_size
    if cards.size != 52
      errors.add(:base, "Deck must have exactly 52 cards.")
      throw(:abort) #Prevents saving or updating deck
    end
  end
end
