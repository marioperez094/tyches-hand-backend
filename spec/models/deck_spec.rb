require 'rails_helper'

RSpec.describe Deck, type: :model do
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

  let!(:player) { create(:player) }
  let!(:deck) { player.deck }

  describe 'Validations' do
    it 'is valid with a name and a unique player_id' do
      expect(deck).to be_valid
    end

    it 'is invalid without a name' do
      deck.name = nil
      expect(deck).not_to be_valid
    end

    it 'does not allow a name longer than 25 characters' do
      deck.name = 'A' * 26
      expect(deck).not_to be_valid
    end

    it 'is invalid without a player' do
      deck.player = nil
      expect(deck).not_to be_valid
    end

    it 'does not allow multiple decks for the same player' do
      another_deck = build(:deck, player: player)
      expect(another_deck).not_to be_valid
    end
  end

  describe '#validate_player_deck' do
    it 'there is no error if there are 52 unique cards' do
      expect(deck.cards.count).to be(52)
      expect(deck).to be_valid
    end

    it 'ensures the deck does not go over 52 cards' do
      card = create(:card)
      player = create(:player)

      collection = player.card_collections.create!(card: card)
      equipped = EquippedCard.create(deck: deck, card_collection: collection)

      expect(deck.reload).not_to be_valid
      expect(deck.errors.full_messages).to include("deck must have exactly 52 cards.")
    end

    
    it 'ensures the deck does not go under 52 cards' do
      deck.equipped_cards.first.destroy

      expect(deck.reload).not_to be_valid
      expect(deck.errors.full_messages).to include("deck must have exactly 52 cards.")
    end

    it 'ensures no duplicate cards can be added' do
      player = create(:player)
      deck.equipped_cards.first.destroy!

      collection = deck.equipped_cards.second.card_collection
      expect { EquippedCard.create(deck: deck, card_collection: collection) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'Associations' do
    let(:card) { create(:card) }

    it 'belongs to a player' do
      expect(deck.player).to eq(player)
    end

    it 'has many equipped cards and destroys association when deleted' do
      expect(deck.equipped_cards.size).to eq(52)
      expect { deck.destroy }.to change { EquippedCard.count }.by(-52)
    end

  end

  describe 'Instance Methods' do
    describe '#set_default_name' do
      it 'assigns the correct name' do
        expect(deck.name).to eq("#{player.username}'s Deck")
      end
    end
  end
end