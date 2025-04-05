require 'rails_helper'

RSpec.describe EquippedToken, type: :model do
  describe 'Validations' do
    let(:token) { create(:token) }
    let(:player) { create(:player) }
    let(:slot) { player.inscribed_slot }

    before do
      player.tokens << token
    end

    it 'has a slot and a token collection' do
      collection = player.token_collections.find_by(token: token)

      equipped_token = EquippedToken.create!(token_collection: collection, slot: slot)
    
      expect(equipped_token).to be_valid
    end

    it 'is invalid without a status' do
      collection = player.token_collections.find_by(token: token)

      equipped_token = build(:equipped_token, token_collection: collection, slot: slot, status: nil)
      expect(equipped_token).not_to be_valid
    end

    it 'is invalid with an invalid status' do
      collection = player.token_collections.find_by(token: token)

      equipped_token = EquippedToken.create!(token_collection: collection, slot: slot)
      expect { equipped_token.status = :win }.to raise_error(ArgumentError)
    end

    context 'equipped token' do
      before do
        collection = player.token_collections.find_by(token: token)
        slot.create_equipped_token!(token_collection: collection)
      end

      it 'has a token and a slot' do
        expect(slot.equipped_token.slot).to eq(slot)
        expect(slot.equipped_token.token_collection.token).to eq(token)
      end

      it 'is invalid if token is already equipped in another slot' do
        collection = player.token_collections.find_by(token: token)
        oathbound_slot = player.slots.by_slot_type('Oathbound').first
    
        equipped_token = EquippedToken.new(token_collection: collection, slot: oathbound_slot)
    
        expect(equipped_token).not_to be_valid
        expect(equipped_token.errors[:token_id]).to include('is already assigned to another slot.')
      end

      it 'is valid if moving the token to a different slot' do
        collection = player.token_collections.find_by(token: token)
        oathbound_slot = player.slots.by_slot_type('Oathbound').first
        slot.equipped_token.destroy

        equipped_token = EquippedToken.new(token_collection: collection, slot: oathbound_slot)
    
        expect(equipped_token).to be_valid
      end
    end
  end
end
