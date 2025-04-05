class TokenCollection < ApplicationRecord
  belongs_to :player
  belongs_to :token

  has_one :equipped_token, dependent: :destroy
end
