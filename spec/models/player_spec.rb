require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'validations' do
    it 'is valid with a username and password' do
      player = build(:player)
      expect(player).to be_valid
    end

    it 'is invalid without a username (unless guest)' do
      player = build(:player, username: nil, is_guest: false)
      expect(player).not_to be_valid
      expect(player.errors[:username]).to include("can't be blank")
    end

    it 'is invalid with a duplicate username' do
      create(:player, username: 'UniqueName')
      duplicate_player = build(:player, username: 'UniqueName')
      expect(duplicate_player).not_to be_valid
    end

    it 'requires a password of at least 6 characters (unless guest)' do
      player = build(:player, password: '123', password_confirmation: '123')
      expect(player).not_to be_valid
      expect(player.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'requires password confirmation (unless guest)' do
      player = build(:player, password: 'password123', password_confirmation: nil)
      expect(player).not_to be_valid
      expect(player.errors[:password_confirmation]).to include("can't be blank")
    end
  end

  describe 'guest player behavior' do
    it 'automatically assigns a guest username' do
      guest = create(:guest_player)
      expect(guest.username).to match(/^Guest\d+$/)
    end

    it 'does not require a password for guest players' do
      guest = build(:guest_player)
      expect(guest).to be_valid
    end
  end

  describe 'blood_pool validation' do
    it 'is invalid if blood_pool is negative' do
      player = build(:player, blood_pool: -100)
      expect(player).not_to be_valid
      expect(player.errors[:blood_pool]).to include('must be greater than or equal to 0')
    end

    it 'is invalid if blood_pool exceeds 5000' do
      player = build(:player, blood_pool: 6000)
      expect(player).not_to be_valid
      expect(player.errors[:blood_pool]).to include('must be less than or equal to 5000')
    end
  end

  describe 'lore_progression validation' do
    it 'is invalid if lore_progression is negative' do
      player = build(:player, lore_progression: -1)
      expect(player).not_to be_valid
      expect(player.errors[:lore_progression]).to include('must be greater than or equal to 0')
    end
  end
end
