require 'rails_helper'

RSpec.describe Round, type: :model do
  describe 'Validations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player) }
    let(:round) { game.round }

    context 'basic attributes' do
      it 'is valid with all attributes' do
        expect(round).to be_valid
      end

      it 'is invalid without a status' do
        round.status = nil
        expect(round).not_to be_valid
      end

      it 'is invalid with an incorrect winner status' do
        expect { round.status = :win }.to raise_error(ArgumentError)
      end

      it 'cannot have duplicate card ids' do
        round.shuffled_deck = [1, 1] + (3..49).to_a
        expect(round).not_to be_valid
        expect(round.errors.full_messages).to include('Shuffled deck contains duplicate card IDs.')
      end
    end

    context 'numeric fields' do
      [
        :card_count,
        :hands_played,
        :player_max_blood_pool,
        :daimon_blood_pool,
        :daimon_max_blood_pool,
      ].each do |field|
        it "requires #{field} to be present" do
          round.send("#{field}=", nil)
          expect(round).not_to be_valid
          expect(round.errors[field]).to include("can't be blank")
        end

        it "requires #{field} to be a number" do
          round.send("#{field}=", 's')
          expect(round).not_to be_valid
          expect(round.errors[field]).to include('is not a number')
        end

        it "requires #{field} to be greater than or equal to 0" do
          round.send("#{field}=", -1)
          expect(round).not_to be_valid
          expect(round.errors[field]).to include('must be greater than or equal to 0')
        end
      end
    end
  end

  describe 'Associations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player) }
    let!(:round) { game.round }
    let!(:hand) { create(:hand, round: round) }

    it 'belongs to a game' do
      expect(round.game).to eq(game)
    end

    it 'belongs to a daimon' do
      expect(round.daimon).to eq(daimon)
    end

    it 'has a hand and destroys when deleted' do
      expect(round.hand).to eq(hand)
      expect{ round.destroy }.to change { Hand.count }.by(-1)
    end
  end

  describe 'Instance Methods' do
    let!(:standard_cards) do
      suits = Card::SUITS
      ranks = Card::RANKS
      suits.product(ranks).map do |suit, rank|
        create(:card,
          effect: 'Standard',
          suit: suit,
          rank: rank
        )
      end
    end
    
    let!(:player) { create(:player, tutorial_finished: true) }
    let!(:daimon) { create(:daimon) }
    let!(:game){ create(:game, player: player) }
    let!(:round){ game.round }

    context '#shuffle_deck_on_create' do
      let!(:new_round) { game.build_round(
        daimon: daimon,
        daimon_blood_pool: 1,
        daimon_max_blood_pool: 1,
      )}

      it 'does not shuffle a deck if it is present' do
        shuffled_deck = round.reshuffle_if_empty
        new_round.shuffled_deck = shuffled_deck

        new_round.save!
        
        expect(game.round).not_to eq(round)
        expect(new_round.shuffled_deck).to eq(shuffled_deck)
      end

      it 'sets a shuffled a deck if one is not present' do
        expect(new_round.shuffled_deck).to eq([])

        new_round.save!
        
        expect(game.round).not_to eq(round)
        expect(new_round.shuffled_deck).to be_an(Array)
        expect(new_round.shuffled_deck).not_to eq([])
      end
    end

    context '#reshuffle_if_empty' do
      it 'reshuffles an empty shuffled deck' do
        original_deck = round.shuffled_deck
        round.shuffled_deck = []
        round.discard_pile = original_deck

        expect(round.shuffled_deck).to eq([])

        round.reshuffle_if_empty

        expect(round.shuffled_deck).not_to be_empty
        expect(round.discard_pile).to eq([])
        expect(round.shuffled_deck).to be_an(Array)
      end

      it 'does nothing if the deck is not empty' do
        original_deck = round.shuffled_deck.dup
        round.reshuffle_if_empty
        expect(round.shuffled_deck).to eq(original_deck)
      end
    end
  end
end