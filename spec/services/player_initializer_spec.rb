# spec/services/player_initializer_spec.rb
require 'rails_helper'

RSpec.describe PlayerInitializer, type: :service do
  let(:player) { create(:player) }
  
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
  
  subject(:initializer) { described_class.new(player) }

  describe "#call" do
    before do
      initializer.call
      player.reload
    end

    it "creates a deck for the player" do
      expect(player.deck).to be_present
    end

    it "populates the deck with exactly 52 standard cards" do
      expect(player.deck.cards.count).to eq(52)
    end

    it "associates the deck's cards with the player" do
      expect(player.cards).to match_array(player.deck.cards)
    end
  end
end
