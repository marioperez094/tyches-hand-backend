class Player < ApplicationRecord
  #Associations
  has_one :deck, dependent: :destroy
  has_many :equipped_cards, through: :deck, source: :cards

  has_many :slots, dependent: :destroy
  has_many :equipped_tokens, through: :slots
  has_many :loadout_tokens, through: :equipped_tokens, source: :token

  has_many :card_collections, dependent: :destroy
  has_many :cards, through: :card_collections

  has_many :token_collections, dependent: :destroy
  has_many :tokens, through: :token_collections

  has_many :games, dependent: :destroy
  
  #Callbacks 
  before_validation :assign_guest_username, if: :guest?
  before_destroy :prevent_registered_player_deletion, unless: :force_delete?
  after_create :initialize_player_resources

  #Secure password with bcrypt
  has_secure_password validations: false

  #Scopes
  scope :by_guests, ->(is_guest) { where(is_guest: is_guest) }

  #Validations
  validates :username, presence: true, uniqueness: true, unless: :guest?
  validates :password, confirmation: true, length: { minimum: 6 },
            presence: true, on: [
              :create, :update_password, :convert_to_registered, :destroy
            ], unless: :guest?
  validates :password_confirmation, presence: true, on: [:create, :update_password, :destroy], unless: :guest?
  validates :blood_pool, :max_blood_pool, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5000 }
  validates :lore_progression, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attr_accessor :force_delete #Allows manual delition when explicitly request 

  def owns_card?(card_id)
    cards.exists?(card_id)
  end

  def owns_token?(token_id)
    tokens.exists?(token_id)
  end

  #Updates changes to player health
  def update_player_health(amount)
    return if amount.zero?
  
    self.blood_pool += amount
    self.blood_pool = [self.blood_pool, max_blood_pool].min #Prevent overhealing
    self.blood_pool = [self.blood_pool, 0].max #Prevent going below 0
    save!
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
