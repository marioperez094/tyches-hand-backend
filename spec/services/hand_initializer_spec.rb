require 'rails_helper'

RSpec.describe HandInitializer do
  let!(:standard_cards) do
    Card::EFFECTS.each do |effect|
      Card::SUITS.each do |suit|
        Card::RANKS.each do |rank|
          FactoryBot.create(:card, rank: rank, suit: suit, effect: effect)
        end
      end
    end
  end

  let!(:player) { create(:player, blood_pool: 5000) }
  let!(:token) { create(:token) }
  let!(:daimon) { create(:daimon) }
  let!(:game) { create(:game, player: player) }
  let!(:round) { game.round }
    
  subject(:initializer) { described_class.new(round) }

  describe '#call' do
    context 'when round is in progress' do
      it 'builds a new hand with correct player and daimon hands' do
        hand = initializer.call

        expect(hand).to be_a(Hand)
        expect(hand.player_hand.size).to eq(2)
        expect(hand.daimon_hand.size).to eq(1)
        expect(hand.blood_wager).to be > 0
      end

      it 'decreases blood_pool for both player and daimon' do
        expect {initializer.call }.to change { player.reload.blood_pool }.by(-500)
                                      .and change {round.reload.daimon_blood_pool }.by(-500)
      end

      it 'applies token, daimon, and card effects' do
        expect(ApplyEffectService).to receive(:apply_token_effects).at_least(:once).and_call_original
        expect(ApplyEffectService).to receive(:apply_daimon_effects).at_least(:once).and_call_original
        initializer.call
      end
    end

    context 'when a hand exists and is in progress' do
      it 'does not destroy the existing hand' do
        hand = create(:hand, round: round)

        expect { initializer.call }.to raise_error('A hand is already active.')
        expect(round.reload.hand).to eq(hand)
      end
    end
  end

  describe 'calculates the changes' do
    context 'with daimon damaging cards' do
      before do
        round.update!(shuffled_deck: [53, 65, 266, 281])
      end
      
      it 'returns the correct damage' do
        hand = initializer.call

        expect(hand.player_hand).to eq([53, 65])
        expect(round.daimon_blood_pool).to be(2500 - 500 - 250 - 33)
      end
    end

    context 'with daimon damaging tokens' do
      before do
        collection = player.token_collections.create!(token: token)
        player.inscribed_slot.create_equipped_token(token_collection: collection)
      end

      it 'returns the correct damage' do
        hand = initializer.call

        expect(player.inscribed_slot.reload.active_effect_type).to eq('damage_daimon_limit_health')
        expect(round.daimon_blood_pool).to be(2500 - 500 - 75)
      end
    end

    context 'with daiomon damaging tokens and cards' do
      before do
        collection = player.token_collections.create!(token: token)
        player.inscribed_slot.create_equipped_token(token_collection: collection)
        round.update!(shuffled_deck: [53, 65, 266, 281])
      end

      it 'returns the correct damage' do
        hand = initializer.call

        expect(player.inscribed_slot.reload.active_effect_type).to eq('damage_daimon_limit_health')
        expect(hand.player_hand).to eq([53, 65])
        expect(round.daimon_blood_pool).to be(2500 - 500 - 75 - 250 - 33)
      end
    end
  end
end