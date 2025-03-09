
require 'rails_helper'

RSpec.describe PlayerInitializer, type: :service do

  # Create 52 standard cards in the database.
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

  let(:player) { create(:player) }

  subject(:initializer) { described_class.new(player) }

  describe "#call" do
    it "creates a deck for the player" do
      expect(player.deck).to be_present
    end

    it "populates the deck with exactly 52 standard cards" do
      expect(player.deck.cards.count).to eq(52)
    end

    it "associates the deck's cards with the player" do
      expect(player.cards).to match_array(player.deck.cards)
    end

    it "creates slots for the player" do
      expect(player.slots.count).to eq(6)
    end

    it "creates 1 Inscribed slot" do
      expect(player.slots.by_slot_type("Inscribed").count).to eq(1)
    end
    
    it "creates 2 Oathbound slots" do
      expect(player.slots.by_slot_type("Oathbound").count).to eq(2)
    end

    it "creates 3 Offering slots" do
      expect(player.slots.by_slot_type("Offering").count).to eq(3)
    end
  end
end