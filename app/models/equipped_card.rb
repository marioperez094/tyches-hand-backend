class EquippedCard < ApplicationRecord
  belongs_to :card
  belongs_to :deck
end
