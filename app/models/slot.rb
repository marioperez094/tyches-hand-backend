class Slot < ApplicationRecord
  #Associations
  belongs_to :player

  has_one :equipped_token, dependent: :destroy
  has_one :token_collection, through: :equipped_token
  has_one :token, through: :token_collection

  #Constants
  SLOT_TYPES = {
    'Inscribed' => %i[inscribed_effect_type inscribed_effect_values],
    'Oathbound' => %i[oathbound_effect_type oathbound_effect_values],
    'Offering'  => %i[offering_effect_type offering_effect_values]
  }.freeze


  #Scopes
  scope :by_slot_type, ->(type) { where(slot_type: type) }

  #Validations
  validates :slot_type, presence: true, inclusion: { in: SLOT_TYPES.keys }
  validate :slot_limits

  def convert_to_collection_ids(token_ids)
    player.token_collections.where(token_id: token_ids)
  end

  def active_effect_type
    return nil unless equipped_token
  
    effect_type_field = SLOT_TYPES[slot_type]&.first
    token&.public_send(effect_type_field)
  end 

  def active_effect_values
    return nil unless equipped_token

    effect_value_field = SLOT_TYPES[slot_type]&.last
    token&.public_send(effect_value_field)
  end 

  private

  def slot_limits
    return unless player
    
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
