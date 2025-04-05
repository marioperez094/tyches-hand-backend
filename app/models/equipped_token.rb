class EquippedToken < ApplicationRecord
  ### Associations
  belongs_to :slot
  belongs_to :token_collection

  ### Constants
  enum :status, { active: 0, inactive: 1, burned: 2}

  ### Validations
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validate :token_must_be_unique_per_player

  private

  def token_must_be_unique_per_player
    token_id = token_collection.token_id

    #Validates a player can only have one token in one slot
    existing_slot = slot.player.slots
      .joins(:equipped_token => :token_collection)
      .where(token_collections: { token_id: token_id })
      #Excludes current slot from search results
      .where.not(slots: { id: slot.id })
      .first

    if existing_slot
      errors.add(:token_id, "is already assigned to another slot.")
    end
  end
end
