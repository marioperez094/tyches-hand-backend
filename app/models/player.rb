class Player < ApplicationRecord

  #Secure password with bcrypt
  has_secure_password validations: false

  #Validations
  validates :username, presence: true, uniqueness: true, unless: :guest?
  validates :password, confirmation: true, length: { minimum: 6 },
            presence: true, on: [
              :create, :update_password, :convert_to_registered, :destroy
            ], unless: :guest?
  validates :password_confirmation, presence: true, on: [:create, :update_password, :destroy], unless: :guest?
  validates :blood_pool, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5000 }
  validates :lore_progression, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  #Callbacks 
  before_validation :assign_guest_username, if: :guest?

  private

  def guest?
    !!is_guest
  end

  #Assign a unique username to gust users
  def assign_guest_username
    update!(username: "Guest#{ Time.now.to_i }") if username.blank?
  end
end
