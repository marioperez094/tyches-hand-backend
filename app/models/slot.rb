class Slot < ApplicationRecord
  #Associations
  belongs_to :player

  has_one :equipped_token, dependent: :destroy
  has_one :token, through: :equipped_token

  #Constants
  SLOT_TYPES = %w[Inscribed Oathbound Offering].freeze

  #Scopes
  scope :by_slot_type, ->(type) { where(slot_type: type) }

  #Validations
  validates :slot_type, presence: true, inclusion: { in: SLOT_TYPES }
  validate :slot_limits

  private

  def slot_limits
    case slot_type
    when "Inscribed"
      if player.slots.where(slot_type: "Inscribed").count >= 1
        errors.add(:slot_type, "Player can only have 1 Inscribed slot.")
      end
    when "Oathbound"
      if player.slots.where(slot_type: "Oathbound").count >= 2
        errors.add(:slot_type, "Player can only have 2 Oathbound slots.")
      end
    when "Offering"
      if player.slots.where(slot_type: "Offering").count >= 3
        errors.add(:slot_type, "Player can only have 3 Offering slots.")
      end
    end
  end
end
