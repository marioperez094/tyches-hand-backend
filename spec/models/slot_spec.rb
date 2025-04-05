require 'rails_helper'

RSpec.describe Slot, type: :model do
  let!(:player) { create(:player) }
  let(:token) { create(:token)}

  let(:inscribed_slot)   { player.slots.find_by(slot_type: 'Inscribed') }
  let(:oathbound_slot_1) { player.slots.where(slot_type: 'Oathbound').first }
  let(:oathbound_slot_2) { player.slots.where(slot_type: 'Oathbound').second }
  let(:offering_slot_1)  { player.slots.where(slot_type: 'Offering').first }
  let(:offering_slot_2)  { player.slots.where(slot_type: 'Offering').second }
  let(:offering_slot_3)  { player.slots.where(slot_type: 'Offering').third }

  before do
    player.tokens << token
  end

  describe 'Validations' do
    it 'is valid with a slot_type and unique player_id' do
      expect(player.inscribed_slot).to eq(inscribed_slot)
      expect(player.slots.where(slot_type: 'Oathbound').first).to eq(oathbound_slot_1)
      expect(player.slots.where(slot_type: 'Oathbound').second).to eq(oathbound_slot_2)
      expect(player.slots.where(slot_type: 'Offering').first).to eq(offering_slot_1)
      expect(player.slots.where(slot_type: 'Offering').second).to eq(offering_slot_2)
      expect(player.slots.where(slot_type: 'Offering').third).to eq(offering_slot_3)

      expect(player.slots.count).to eq(6)
    end  
    
    it 'is invalid without a player' do
      inscribed_slot.player = nil
      expect(inscribed_slot).not_to be_valid
    end

    it 'allows player to have 1 Inscribed slot' do
      slot = player.slots.where(slot_type: 'Inscribed').count
      expect(slot).to eq(1)
    end

    it 'allows player to have 2 Oathbound slots' do
      slot = player.slots.where(slot_type: 'Oathbound').count
      expect(slot).to eq(2)
    end

    it 'allows player to have 3 Offering slots' do
      slot = player.slots.where(slot_type: 'Offering').count
      expect(slot).to eq(3)
    end

    it 'prevents creating more than 1 inscribed slot' do
      extra_slot = player.slots.build(slot_type: 'Inscribed')
      expect(extra_slot).not_to be_valid
      expect(extra_slot.errors[:slot_type]).to include('Player can only have 1 Inscribed slot.')
    end

    it 'prevents creating more than 2 Oathbound slots' do
      extra_slot = player.slots.build(slot_type: 'Oathbound')
      expect(extra_slot).not_to be_valid
      expect(extra_slot.errors[:slot_type]).to include('Player can only have 2 Oathbound slots.')
    end

    it 'prevents creating more than 3 Offering slots' do
      extra_slot = player.slots.build(slot_type: 'Offering')
      expect(extra_slot).not_to be_valid
      expect(extra_slot.errors[:slot_type]).to include('Player can only have 3 Offering slots.')
    end

    it 'requires a valid slot_type' do
      invalid_slot = player.slots.build(slot_type: 'InvalidSlot')
      expect(invalid_slot).not_to be_valid
      expect(invalid_slot.errors[:slot_type]).to include('is not included in the list')
    end

    it 'ensures a token can only occupy one slot at a time' do
      token_collection = player.token_collections.find_by(token: token)
      inscribed_slot.create_equipped_token!(token_collection: token_collection)

      expect(inscribed_slot.token).to eq(token)

      expect {
        oathbound_slot_1.create_equipped_token!(token_collection: token_collection)
      }.to raise_error(ActiveRecord::RecordInvalid, /Token is already assigned to another slot/)

      expect(inscribed_slot.token).to eq(token)
      expect(oathbound_slot_1.token).to be_nil
    end

    it 'allows a token to move to a new slot only if removed first' do
      token_collection = player.token_collections.find_by(token: token)
      inscribed_slot.create_equipped_token!(token_collection: token_collection)
      expect(inscribed_slot.token).to eq(token)

      inscribed_slot.equipped_token = nil

      oathbound_slot_1.create_equipped_token!(token_collection: token_collection)

      expect(oathbound_slot_1.token).to eq(token)
      expect(inscribed_slot.reload.token).to be_nil
    end
  end

  describe 'Associations' do
    let(:token) { create(:token) }

    it 'belongs to a player' do
      expect(inscribed_slot).not_to be_nil
      expect(inscribed_slot.player).to eq(player)
    end

    it 'can have a token assigned to it' do
      token_collection = player.token_collections.find_by(token: token)
      inscribed_slot.create_equipped_token!(token_collection: token_collection)

      expect(inscribed_slot.token).to eq(token)
    end
  end

  describe 'Scopes' do
    it 'by_slot_type returns only the inscribed slots by type' do
      expect(Slot.by_slot_type('Inscribed')).to include(inscribed_slot)
      expect(Slot.by_slot_type('Inscribed')).not_to include([oathbound_slot_1, oathbound_slot_2, offering_slot_1, offering_slot_2, offering_slot_3])
    end 
    
    it 'by_slot_type returns only the oathbound slots by type' do
      expect(Slot.by_slot_type('Oathbound')).to eq([oathbound_slot_1, oathbound_slot_2])
      expect(Slot.by_slot_type('Oathbound')).not_to include([inscribed_slot, offering_slot_1, offering_slot_2, offering_slot_3])
    end 
    
    it 'by_slot_type returns only the offering slots by type' do
      expect(Slot.by_slot_type('Offering')).to eq([offering_slot_1, offering_slot_2, offering_slot_3])
      expect(Slot.by_slot_type('Offering')).not_to include([inscribed_slot, oathbound_slot_1, oathbound_slot_2])
    end 
  end

  describe 'Instance Method' do
    let(:token) { create(:token) }
    let(:player) { create(:player, username: 'new_player') }
    let(:slot) { player.inscribed_slot }

    before do   
      collection = player.token_collections.find_by(token: token)
      slot.create_equipped_token!(token_collection: collection)
    end
    
    describe '#active_effect_type' do
      it 'returns the correct effect_type' do
        inscribed_effect = token.inscribed_effect_type
        oathbound_effect = token.oathbound_effect_type
        offering_effect = token.offering_effect_type
        
        expect(slot.active_effect_type).to eq(inscribed_effect)
        expect(slot.active_effect_type).not_to eq(oathbound_effect)
        expect(slot.active_effect_type).not_to eq(offering_effect)
      end
    end

    describe '#active_effect_type' do
      it 'returns the correct effect_value' do
        inscribed_effect = token.inscribed_effect_values
        oathbound_effect = token.oathbound_effect_values
        offering_effect = token.offering_effect_values
        
        expect(slot.active_effect_values).to eq(inscribed_effect)
        expect(slot.active_effect_values).not_to eq(oathbound_effect)
        expect(slot.active_effect_values).not_to eq(offering_effect)
      end
    end
  end
end