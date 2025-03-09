require 'rails_helper'

RSpec.describe Slot, type: :model do
  let(:player) { create(:player) }
  let(:token) { create(:token)}

  let!(:inscribed_slot) { player.slots.find_by(slot_type: "Inscribed") }
  let!(:oathbound_slot) { player.slots.find_by(slot_type: "Oathbound") }
  let!(:offering_slot) { player.slots.find_by(slot_type: "Offering") }

  describe "Validations" do
    it 'allows player to have 1 Inscribed slot' do
      slot = player.slots.where(slot_type: "Inscribed").count
      expect(slot).to eq(1)
    end

    it 'allows player to have 2 Oathbound slots' do
      slot = player.slots.where(slot_type: "Oathbound").count
      expect(slot).to eq(2)
    end

    it 'allows player to have 3 Offering slots' do
      slot = player.slots.where(slot_type: "Offering").count
      expect(slot).to eq(3)
    end

    it 'prevents creating more than 1 inscribed slot' do
      extra_slot = player.slots.build(slot_type: "Inscribed")
      expect(extra_slot).not_to be_valid
      expect(extra_slot.errors[:slot_type]).to include("Player can only have 1 Inscribed slot.")
    end

    it 'prevents creating more than 2 Oathbound slots' do
      extra_slot = player.slots.build(slot_type: "Oathbound")
      expect(extra_slot).not_to be_valid
      expect(extra_slot.errors[:slot_type]).to include("Player can only have 2 Oathbound slots.")
    end

    it 'prevents creating more than 3 Offering slots' do
      extra_slot = player.slots.build(slot_type: "Offering")
      expect(extra_slot).not_to be_valid
      expect(extra_slot.errors[:slot_type]).to include("Player can only have 3 Offering slots.")
    end

    it "requires a valid slot_type" do
      invalid_slot = player.slots.build(slot_type: "InvalidSlot")
      expect(invalid_slot).not_to be_valid
      expect(invalid_slot.errors[:slot_type]).to include("is not included in the list")
    end

    it 'ensures a token can only occupy one slot at a time' do
      inscribed_slot.create_equipped_token!(token: token)

      expect(inscribed_slot.token).to eq(token)

      expect {
        oathbound_slot.create_equipped_token!(token: token)
      }.to raise_error(ActiveRecord::RecordInvalid, /Token is already assigned to another slot/)

      expect(inscribed_slot.token).to eq(token)
      expect(oathbound_slot.token).to be_nil
    end

    it 'allows a token to move to a new slot only if removed first' do
      inscribed_slot.create_equipped_token!(token: token)
      expect(inscribed_slot.token).to eq(token)

      inscribed_slot.token = nil

      oathbound_slot.create_equipped_token!(token: token)

      expect(oathbound_slot.token).to eq(token)
      expect(inscribed_slot.token).to be_nil
    end
  end

  describe "Associations" do
    let(:token) { FactoryBot.create(:token) }

    it "belongs to a player" do
      slot = player.slots.find_by(slot_type: "Inscribed")
      expect(slot).not_to be_nil
      expect(slot.player).to eq(player)
    end

    it "can have a token assigned to it" do
      slot = player.slots.find_by(slot_type: "Inscribed")
      slot.create_equipped_token!(token: token)

      expect(slot.token).to eq(token)
    end
  end
end