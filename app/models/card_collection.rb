class CardCollection < ApplicationRecord
  belongs_to :card
  belongs_to :player

  has_one :equipped_card, dependent: :destroy
end
