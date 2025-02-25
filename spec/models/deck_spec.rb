require 'rails_helper'

RSpec.describe Deck, type: :model do
  let(:player) { create(:player) }
  let!(:deck) { create(:deck, player: player) }

  describe "Validations" do
    it "is valid with a name and a unique player_id" do
      expect(deck).to be_valid
    end

    it "is invalid without a name" do
      deck.name = nil
      expect(deck).not_to be_valid
    end

    it "does not allow a name longer than 25 characters" do
      deck.name = "A" * 26
      expect(deck).not_to be_valid
    end

    it "does not allow multiple decks for the same player" do
      another_deck = build(:deck, player: player)
      expect(another_deck).not_to be_valid
    end
  end

  describe "Associations" do
    it "belongs to a player" do
      expect(deck.player).to eq(player)
    end

    it "can have multiple cards through cards_in_deck" do
      card1 = create(:card)
      card2 = create(:card, effect: "Exhumed")
      EquippedCard.create(deck: deck, card: card1)
      EquippedCard.create(deck: deck, card: card2)

      deck.reload
      expect(deck.cards).to include(card1, card2)
    end

    it "destroys associated cards_in_deck when deleted" do
      card = create(:card)
      EquippedCard.create(deck: deck, card: card)

      expect(EquippedCard.count).to eq(1)
      deck.destroy
      expect(EquippedCard.count).to eq(0)
    end
  end

  describe "Callbacks" do
    it "sets a default name on creation if none is provided" do
      expect(deck.name).to eq("#{player.username}'s Deck")
    end
  end

  describe "Methods" do    
    let!(:standard_cards) { Card.by_effect("Standard") }

    it "populates the deck with 52 standard cards if empty" do
      deck.populate_with_standard_cards
      deck.reload
      expect(deck.cards.count).to eq(52)
    end

    it "does not overwrite existing cards when populating" do
      extra_card = Card.first
      deck.cards << extra_card

      deck.populate_with_standard_cards
      deck.reload

      expect(deck.cards).to include(extra_card)
      expect(deck.cards.count).to eq(53)
    end
  end

  describe "Custom Validations" do
    it "ensures the deck has exactly 52 cards unless new" do
      card = create(:card)
      EquippedCard.create(deck: deck, card: card)

      deck.reload

      expect(deck.valid?).to be_falsey
      expect(deck.errors.full_messages).to include("Deck must have exactly 52 cards.")
    end
  end
end