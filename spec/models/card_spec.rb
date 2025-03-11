require 'rails_helper'

RSpec.describe Card, type: :model do
  describe "Validations" do
    it "is valid with a name, suit, rank, effect, and description" do
      card = build(:card)
      expect(card).to be_valid
    end

    it "is invalid without a suit" do
      card = build(:card, suit: nil)
      expect(card).not_to be_valid
    end

    it "is invalid with an incorrect suit" do
      card = build(:card, suit: "Stars")
      expect(card).not_to be_valid
    end

    it "is invalid without a rank" do
      card = build(:card, rank: nil)
      expect(card).not_to be_valid
    end

    it "is invalid with an incorrect rank" do
      card = build(:card, rank: "Joker")
      expect(card).not_to be_valid
    end

    it "is invalid without an effect" do
      card = build(:card, effect: nil)
      expect(card).not_to be_valid
    end

    it "is invalid with an incorrect effect" do
      card = build(:card, effect: "Magic")
      expect(card).not_to be_valid
    end

    it "is invalid with an incorrect effect_type" do
      card = build(:card, effect_type: "Magic") # Invalid type
      expect(card).not_to be_valid
    end

    it "ensures uniqueness of the card name" do
      create(:card, name: "Exhumed Ace of Spades")
      duplicate_card = build(:card, name: "Exhumed Ace of Spades")
      expect(duplicate_card).not_to be_valid
    end
  end

  describe "Associations" do
    let(:card) { create(:card) }
    let(:player) { create(:player) }
    let(:deck) { player.deck }

    it "can be added to a player's collection" do
      collection = CardCollection.create!(player: player, card: card)
      expect(player.cards).to include(card)
      expect(card.players).to include(player)
    end

    it "destroys associated collections when deleted" do
      collection = CardCollection.create!(player: player, card: card)

      expect(CardCollection.count).to eq(1)
      card.destroy! 

      expect(CardCollection.count).to eq(0)
    end
  end

  describe "Instance Methods" do
    let(:card) { create(:card, rank: "Ace", suit: "Spades", effect: "Exhumed") }

    it "card_numeric_rank returns correct value" do
      expect(card.card_numeric_rank).to eq(15)  # Ace should return 15
    end

    it "set_card_name assigns the correct name" do
      expect(card.name).to eq("Exhumed Ace of Spades")
    end

    it "calculate_effect_value returns the correct value" do
      expected_value = (1 + 0.5 * 15 / 15.0).round  # Based on Exhumed effect
      expect(card.calculate_effect_value).to eq(expected_value)
    end

    it "generates the correct description" do
      expect(card.description).to include("Cards ripped from a corpse's stiff grip.")
    end

    it "generates the correct effect description" do
      expect(card.effect_description).to include("Increases blood pot payout on a win.")
    end

    it "automatically assigns effect_type based on effect" do
      card = create(:card, effect: "Exhumed")
      expect(card.effect_type).to eq("Pot")
    end
    
    it "assigns 'none' to Standard cards" do
      card = create(:card, effect: "Standard")
      expect(card.effect_type).to eq("None")
    end
  end

  describe "Scopes" do
    let!(:spade_card) { create(:card, suit: "Spades") }
    let!(:heart_card) { create(:card, suit: "Diamonds") }
    let!(:exhumed_card) { create(:card, effect: "Exhumed") }
    let!(:charred_card) { create(:card, effect: "Charred") }
    let!(:player) { create(:player) }
    let!(:player_owned_card) { create(:card) }
    let!(:pot_card) { create(:card, effect: "Blessed") } # damage
    let!(:heal_card) { create(:card, rank: "King", effect: "Charred") } # heal

    before do
      player.cards << player_owned_card
    end

    it ".by_suit returns cards of the given suit" do
      expect(Card.by_suit("Spades")).to include(spade_card)
      expect(Card.by_suit("Spades")).not_to include(heart_card)
    end

    it ".by_effect returns cards with the given effect" do
      expect(Card.by_effect("Exhumed")).to include(exhumed_card)
      expect(Card.by_effect("Exhumed")).not_to include(charred_card)
    end

    it ".by_undiscovered returns cards the player has not discovered" do
      undiscovered_cards = Card.by_undiscovered(player)
      expect(undiscovered_cards).to include(spade_card, heart_card, exhumed_card, charred_card)
      expect(undiscovered_cards).not_to include(player_owned_card)
    end

    it ".by_effect_type returns cards with the given effect type" do
      expect(Card.by_effect_type("Pot")).to include(pot_card)
      expect(Card.by_effect_type("Pot")).not_to include(heal_card)
    
      expect(Card.by_effect_type("Heal")).to include(heal_card)
      expect(Card.by_effect_type("Heal")).not_to include(pot_card)
    end
  end
end