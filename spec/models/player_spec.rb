require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'Validations' do
    let(:player) { build(:player) }

    context 'basic attributes' do
      it 'is valid with a username and password' do
        expect(player).to be_valid
      end

      it 'is invalid without a username (unless guest)' do
        player.username = nil
        player.is_guest = false
        expect(player).not_to be_valid
        expect(player.errors[:username]).to include("can't be blank")
      end

      it 'is invalid with a duplicate username' do
        create(:player, username: 'UniqueName')
        duplicate_player = build(:player, username: 'UniqueName')
        expect(duplicate_player).not_to be_valid
      end

      it 'requires a password (unless guest)' do
        player.password = nil
        player.password_confirmation = nil
        expect(player).not_to be_valid
        expect(player.errors[:password]).to include('is too short (minimum is 6 characters)')
      end

      it 'requires a password of at least 6 characters' do
        player.password = '123'
        player.password_confirmation = '123'
        expect(player).not_to be_valid
        expect(player.errors[:password]).to include('is too short (minimum is 6 characters)')
      end

      it 'requires password confirmation' do
        player.password = 'password123'
        player.password_confirmation = nil
        expect(player).not_to be_valid
        expect(player.errors[:password_confirmation]).to include("can't be blank")
      end
    end

    context 'boolean fields' do
      it 'requires is_guest to be true or false' do
        player.is_guest = nil
        expect(player).not_to be_valid
        expect(player.errors[:is_guest]).to include('is not included in the list')
      end

      it 'requires tutorial_finished to be true or false' do
        player.tutorial_finished = nil
        expect(player).not_to be_valid
        expect(player.errors[:tutorial_finished]).to include('is not included in the list')
      end
    end

    context 'numeric fields' do
      [
        :blood_pool,
        :max_daimon_health_reached,
        :max_round_reached,
        :games_played,
        :story_progression
      ].each do |field|
        it "requires #{field} to be present" do
          player.send("#{field}=", nil)
          expect(player).not_to be_valid
          expect(player.errors[field]).to include("can't be blank")
        end

        it "requires #{field} to be a number" do
          player.send("#{field}=", 's')
          expect(player).not_to be_valid
          expect(player.errors[field]).to include('is not a number')
        end

        it "requires #{field} to be greater than or equal to 0" do
          player.send("#{field}=", -1)
          expect(player).not_to be_valid
          expect(player.errors[field]).to include('must be greater than or equal to 0')
        end
      end
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

  describe 'Associations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon, story_sequence: 0) }
    let(:card1) { create(:card) }
    let(:card2) { create(:card, effect: 'Exhumed') }
    let(:token) { create(:token) }
    let(:deck) { player.deck }
    let(:slot) { player.slots.find_by(slot_type: 'Inscribed') }
    let!(:game) { create(:game, player: player) }

    it 'has a deck and deletes it when destroyed' do
      expect(player.deck.name).to eq("#{player.username}'s Deck")
      player.force_delete = true
      expect { player.destroy }.to change { Deck.count }.by(-1)
    end

    it 'has many slots and deletes them when destroyed' do
      expect(player.slots.count).to eq(6)
      player.force_delete = true
      expect { player.destroy }.to change { Slot.count }.by(-6)
    end

    it 'returns the inscribed slot if it exists' do
      expect(player.inscribed_slot).to eq(slot)
    end

    it 'returns nil if no inscribed slot exists' do
      slot.destroy
      player.reload
      expect(player.inscribed_slot).to be_nil
    end

    it 'has many cards and deletes collections when destroyed' do
      player.cards << [card1, card2]
      player.force_delete = true
      expect { player.destroy }.to change { CardCollection.count }.by(-2)
    end

    it 'has many tokens and deletes collections when destroyed' do
      player.tokens << token
      player.force_delete = true
      expect { player.destroy }.to change { TokenCollection.count }.by(-1)
    end

    it 'has many equipped cards and tokens through deck and slots' do
      card_collection = player.card_collections.create!(card: card1)
      token_collection = player.token_collections.create!(token: token)

      deck.equipped_cards.create!(card_collection: card_collection)
      slot.create_equipped_token!(token_collection: token_collection)
      expect(player.assigned_cards).to include(card1)
      expect(player.assigned_tokens).to include(token)
    end

    it 'has a game and deletes it when destroyed' do
      expect(player.game).to eq(game)
      player.force_delete = true
      expect { player.destroy }.to change { Game.count }.by(-1)
    end
  end

  describe 'Scopes' do
    let!(:guest) { create(:player, username: nil, is_guest: true) }
    let!(:player) { create(:player) }

    it 'by_guests returns only guest players' do
      expect(Player.by_guests(true)).to include(guest)
      expect(Player.by_guests(true)).not_to include(player)
    end

    it 'by_guests returns only non-guest players' do
      expect(Player.by_guests(false)).to include(player)
      expect(Player.by_guests(false)).not_to include(guest)
    end
  end

  describe 'Instance Methods' do
    let!(:player) { create(:player, max_round_reached: 2, max_daimon_health_reached: 4000) }
    let!(:guest) { create(:player, username: nil, password: nil, password_confirmation: nil, is_guest: true)}
    let!(:daimon) { create(:daimon, story_sequence: 0) }
    let!(:game) { create(:game, player: player) }
    let(:card) { create(:card) }
    let(:token) { create(:token) }

    describe '#owns_card?' do
      it 'returns true if the player owns the card' do
        player.cards << card
        expect(player.owns_card?(card.id)).to be true
      end

      it 'returns false if the player does not own the card' do
        expect(player.owns_card?(card.id)).to be false
      end
    end

    describe '#owns_token?' do
      it 'returns true if the player owns the token' do
        player.tokens << token
        expect(player.owns_token?(token.id)).to be true
      end

      it 'returns false if the player does not own the token' do
        expect(player.owns_token?(token.id)).to be false
      end
    end

    describe '#update_max_round' do
      context 'when the rounds played exceeds max_round_reached' do
        before do
          game.update!(rounds_played: 5)
          game.round.update!(daimon_max_blood_pool: 6000)
        end

        it 'updates max_round_reached and max_daimon_health_reached' do
          player.update_max_round
          expect(player.max_round_reached).to eq(5)
          expect(player.max_daimon_health_reached).to eq(6000)
        end
      end

      context 'when current round is not greater than max_round_reached' do
        before do
          allow(game).to receive(:rounds_played).and_return(2)
          allow(player).to receive(:game).and_return(game)
        end

        it 'does not update max_round_reached or max_daimon_health_reached' do
          expect { player.update_max_round }.not_to change { player.reload.max_round_reached }
        end
      end
    end

    describe '#unassigned_cards' do
      before do
        player.card_collections.create!(card: card)
      end
      
      it 'returns only cards that are not assigned' do
        expect(player.unassigned_cards).to contain_exactly(card)
      end

      it 'is empty' do
        collection = player.card_collections.find_by(card_id: card.id)
        
        player.deck.equipped_cards.create!(card_collection: collection)
        expect(player.unassigned_cards).to be_empty
      end
    end

    describe '#unassigned_tokens' do
      before do
        player.token_collections.create!(token: token)
      end
      
      it 'returns only cards that are not assigned' do
        expect(player.unassigned_tokens).to contain_exactly(token)
      end

      it 'is empty' do
        collection = player.token_collections.find_by(token_id: token.id)
        
        player.inscribed_slot.create_equipped_token!(token_collection: collection)
        expect(player.unassigned_tokens).to be_empty
      end
    end
  end

  describe 'Game replacement' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:second_daimon) { create(:daimon, name: 'The Wire', rune: 'T', effect_type: 'increase_max_health', story_sequence: 1) }
    let!(:old_game) { create(:game, player: player) }

    it 'destroys the old game and assigns the new round' do
      expect(player.game).to eq(old_game)

      old_game.destroy
      new_game = create(:game, player: player) 
      expect(player.reload.game).to eq(new_game)
      expect(player.game).not_to eq(old_game)
    end
  end
end
