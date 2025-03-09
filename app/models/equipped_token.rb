class EquippedToken < ApplicationRecord
  belongs_to :token
  belongs_to :slot

  validate :token_must_be_unique_per_player

  private

  def token_must_be_unique_per_player
    #Validates a player can only have one token in one slot
    existing_slot = slot.player.slots
      .joins(:equipped_token)
      .where(equipped_tokens: { token_id: token_id })
      #Excludes current slot from search results
      .where.not(slots: { id: slot.id })
      .first

    if existing_slot
      errors.add(:token_id, "is already assigned to another slot.")
    end
  end
end
