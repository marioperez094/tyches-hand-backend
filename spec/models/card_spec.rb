require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'Validations' do
    let(:card) { build(:card) }

    context 'basic attributes' do
      it 'is valid with a name and description' do
        expect(card).to be_valid
      end

      it 'is invalid without a name' do
        allow(card).to receive(:set_card_name)
        card.name = nil
        expect(card).not_to be_valid
        expect(card.errors[:name]).to include("can't be blank")
      end

      it 'is invalid with a duplicate username' do
        create(:card, name: 'UniqueName')
        duplicate_card = build(:card, name: 'UniqueName')
        expect(duplicate_card).not_to be_valid
        expect(duplicate_card.errors[:name]).to include('has already been taken')
      end

      it 'is invalid without a description' do
        allow(card).to receive(:set_effect_details)

        card.description = nil
        expect(card).not_to be_valid
        expect(card.errors[:description]).to include("can't be blank")
      end

      it 'requires suit to be present' do
        card = build(:card, suit: nil)
        allow(card).to receive(:set_card_name)
        expect(card).not_to be_valid
        expect(card.errors[:suit]).to include("can't be blank")
      end

      it 'requires suit to be valid' do
        card = build(:card, suit: 'Stars')
        allow(card).to receive(:set_card_name)
        expect(card).not_to be_valid
        expect(card.errors[:suit]).to include('is not included in the list')
      end

      it 'requires rank to be present' do
        card = build(:card, rank: nil)
        allow(card).to receive(:set_card_name)
        expect(card).not_to be_valid
        expect(card.errors[:rank]).to include("can't be blank")
      end

      it 'requires rank to be valid' do
        card = build(:card, rank: 'Stars')
        allow(card).to receive(:set_card_name)
        expect(card).not_to be_valid
        expect(card.errors[:rank]).to include('is not included in the list')
      end
    end

    context 'list fields set in set_effect_details' do
      [
        :effect,
        :effect_type,
      ].each do |field|
        it "requires #{field} to be present" do
          allow(card).to receive(:set_effect_details)

          card.send("#{field}=", nil)
          expect(card).not_to be_valid
          expect(card.errors[field]).to include("can't be blank")
        end

        it "invalid with an incorrect #{field}" do
          card.send("#{field}=", 'star')
          expect(card).not_to be_valid
          expect(card.errors[field]).to include('is not included in the list')
        end
      end
    end
  end

  describe 'Associations' do
    let(:card) { create(:card) }
    let(:player) { create(:player) }
    let(:deck) { player.deck }

    it 'has a collection and deletes it when destroyed' do
      card.players << player
      expect { card.destroy }.to change { CardCollection.count }.by(-1)
    end
  end

  describe 'Scopes' do
    let!(:spade_card) { create(:card, suit: 'Spades') }
    let!(:heart_card) { create(:card, suit: 'Diamonds') }
    let!(:exhumed_card) { create(:card, effect: 'Exhumed') }
    let!(:charred_card) { create(:card, effect: 'Charred') }
    let!(:player) { create(:player) }
    let!(:player_owned_card) { create(:card) }
    let!(:loss_blood_return) { create(:card, effect: 'Blessed') } # damage
    let!(:heal_player) { create(:card, rank: 'King', effect: 'Charred') } # heal

    before do
      player.cards << player_owned_card
    end

    it '.by_suit returns cards of the given suit' do
      expect(Card.by_suit('Spades')).to include(spade_card)
      expect(Card.by_suit('Spades')).not_to include(heart_card)
    end

    it '.by_effect returns cards with the given effect' do
      expect(Card.by_effect('Exhumed')).to include(exhumed_card)
      expect(Card.by_effect('Exhumed')).not_to include(charred_card)
    end

    it '.by_undiscovered returns cards the player has not discovered' do
      undiscovered_cards = Card.by_undiscovered(player)
      expect(undiscovered_cards).to include(spade_card, heart_card, exhumed_card, charred_card)
      expect(undiscovered_cards).not_to include(player_owned_card)
    end

    it '.by_effect_type returns cards with the given effect type' do
      expect(Card.by_effect_type('loss_blood_return')).to include(loss_blood_return)
      expect(Card.by_effect_type('loss_blood_return')).not_to include(heal_player)
    
      expect(Card.by_effect_type('heal_player')).to include(heal_player)
      expect(Card.by_effect_type('heal_player')).not_to include(loss_blood_return)
    end
  end

  describe 'Instance Methods' do    
    let!(:card) { create(:card, rank: 'Ace', suit: 'Spades', effect: 'Exhumed') }
    
    describe '#card_numeric_rank' do
      it 'card_numeric_rank returns correct value' do
        expect(card.card_numeric_rank).to eq(15)  # Ace should return 11
      end
    end

    describe 'EffectTypes' do
      it 'has the correct effect description from EffectTypes::EFFECT_ACTIONS' do
        expect(EffectTypes::EFFECT_ACTIONS[card.effect_type][:description]).to include('Increases blood pot payout on a win.')
      end
    end
    
    describe '#set_card_name' do
      it 'assigns the correct name' do
        card = Card.create!(suit: 'Hearts', rank: 'Jack', effect: 'Charred')
        expect(card.name).to eq('Charred Jack of Hearts')
      end
    end

    describe 'set_effect_details' do
      let(:card) { create(:card, rank: '2', suit: 'Spades', effect: 'Blessed')}

      it 'assigns the correct description' do
        expect(card.description).to eq('The cards are blinding, and sizzles to the touch.')
      end

      it 'assigns the correct effect_type' do
        expect(card.effect_type).to eq('loss_blood_return')
      end

      it 'assigns the correct effect_value' do
        expected_value = (20 * 2 / 15.0).round(2)  # Based on Blessed effect
        expect(card.effect_values).to eq('player_health' => { 'value' => expected_value, 'apply_on_phase' => 'on_loss'})
      end
    end
  end
end