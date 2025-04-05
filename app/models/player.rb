class Player < ApplicationRecord
  ### Associations

  #Cards
  has_many :card_collections, dependent: :destroy
  has_many :cards, through: :card_collections

  has_one :deck, dependent: :destroy
  has_many :equipped_cards, through: :deck
  has_many :equipped_card_collections, through: :equipped_cards, source: :card_collection
  has_many :assigned_cards, through: :equipped_card_collections, source: :card

  #Tokens
  has_many :token_collections, dependent: :destroy
  has_many :tokens, through: :token_collections

  has_many :slots, dependent: :destroy
  has_many :equipped_tokens, through: :slots
  has_many :equipped_token_collections, through: :equipped_tokens, source: :token_collection
  has_many :assigned_tokens, through: :equipped_token_collections, source: :token

  has_one :inscribed_slot, -> { where(slot_type: 'Inscribed') }, class_name: 'Slot'

  has_one :game, dependent: :destroy
  
  ### Callbacks 
  before_validation :assign_guest_username, if: :guest?
  before_destroy :prevent_registered_player_deletion, unless: :force_delete?
  after_create :initialize_player_resources

  ### Secure password with bcrypt
  has_secure_password validations: false

  ### Scopes
  scope :by_guests, ->(is_guest) { where(is_guest: is_guest) }

  ### Validations
  #Player
  validates :username, presence: true, uniqueness: true, unless: :guest?
  validates :password, confirmation: true, length: { minimum: 6 },
            presence: true, on: [
              :create, :update_password, :convert_to_registered, :destroy
            ], unless: :guest?
  validates :password_confirmation, presence: true, on: [:create, :update_password, :destroy], unless: :guest?
  validates :is_guest, inclusion: { in: [true, false] }

  #Game
  validates :tutorial_finished, inclusion: { in: [true, false] }
  validates :blood_pool, :max_daimon_health_reached, 
            :max_round_reached, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :story_progression, :games_played, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attr_accessor :force_delete #Allows manual delition when explicitly request 

  def owns_card?(card_id)
    cards.exists?(card_id)
  end

  def owns_token?(token_id)
    tokens.exists?(token_id)
  end
  
  #Updates player leaderboard stats
  def update_max_round
    rounds_played = game&.rounds_played
    daimon_blood_pool = game&.round&.daimon_max_blood_pool

    if rounds_played > max_round_reached
      self.max_round_reached = rounds_played
      self.max_daimon_health_reached = daimon_blood_pool
      save!
    end
  end

  def unassigned_cards
    card_collections
      .left_outer_joins(:equipped_card)
      .where(equipped_cards: { id: nil })
      .includes(:card).map(&:card)
  end

  def unassigned_tokens
    token_collections
      .left_outer_joins(:equipped_token)
      .where(equipped_tokens: { id: nil })
      .includes(:token).map(&:token)
  end

  def unequipped_tokens
  end

  private

  def guest?
    !!is_guest
  end

  def force_delete?
    !!@force_delete #Returns true if explicitly set 
  end

  def prevent_registered_player_deletion
    throw(:abort) unless guest? # Prevent destruction if the player is registered
  end

  #Assign a unique username to guest users
  def assign_guest_username
    self.username = "Guest#{ Time.now.to_i }" if username.blank?
  end

  def initialize_player_resources
    PlayerInitializer.new(self).call
  end
end
