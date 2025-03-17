require 'rails_helper'

RSpec.describe CardWeightService, type: :service do
  let(:card1) { create(:card, rank: 10, effect: "Exhumed", suit: "Hearts") }
  let(:card2) { create(:card, rank: 5, effect: "Standard", suit: "Clubs") }
  let(:card3) { create(:card, rank: 7, effect: "Blessed", suit: "Diamonds") }
  let(:cards) { [card1, card2, card3] }

  let(:rank_weights) { ->(card) { card.rank } }
  let(:effect_weights) { ->(card) { card.effect == "Exhumed" ? 1.5 : 1.0 } }
  let(:suit_weights) { ->(card) { ["Hearts", "Diamonds"].include?(card.suit) ? 1.2 : 1.0 } }

  describe ".calculate_card_weights" do
    it "calculates correct weights for each card" do
      weights = CardWeightService.calculate_card_weights(
        cards: cards,
        rank_weights: rank_weights,
        effect_weights: effect_weights,
        suit_weights: suit_weights
      )

      expected_weights = [
        10 * 1.5 * 1.2,  # card1: 10 (rank) * 1.5 (Exhumed) * 1.2 (Hearts)
        5 * 1.0 * 1.0,   # card2: 5 (rank) * 1.0 (Standard) * 1.0 (Clubs)
        7 * 1.0 * 1.2    # card3: 7 (rank) * 1.0 (Blessed) * 1.2 (Diamonds)
      ]

      expect(weights).to eq(expected_weights)
    end

    it "defaults to weight of 1 if no weight functions are provided" do
      weights = CardWeightService.calculate_card_weights(cards: cards)
      expect(weights).to eq([1, 1, 1])
    end
  end

  describe ".randomize_cards_by_weight" do
    let(:weights) { [18.0, 5.0, 8.4] } # Using precomputed weights

    it "selects the correct number of cards" do
      selected_cards = CardWeightService.randomize_cards_by_weight(cards, weights, 2)
      expect(selected_cards.size).to eq(2)
    end

    it "raises an error if cards and weights sizes do not match" do
      expect {
        CardWeightService.randomize_cards_by_weight(cards, [1, 2], 2)
      }.to raise_error(ArgumentError, "Cards and weights size must match")
    end

    it "returns an empty array if count is zero" do
      selected_cards = CardWeightService.randomize_cards_by_weight(cards, weights, 0)
      expect(selected_cards).to be_empty
    end

    it "returns an empty array if cards are empty" do
      selected_cards = CardWeightService.randomize_cards_by_weight([], [], 3)
      expect(selected_cards).to be_empty
    end

    it "selects weighted cards correctly" do
      allow_any_instance_of(Object).to receive(:rand).and_return(1.0)  
      selected_cards = CardWeightService.randomize_cards_by_weight(cards, weights, 1)
      expect(selected_cards.first).to eq(card1)  
    end
  end
end
