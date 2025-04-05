class EquippedCard < ApplicationRecord
  belongs_to :deck
  belongs_to :card_collection
end
