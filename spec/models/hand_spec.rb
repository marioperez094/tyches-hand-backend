require 'rails_helper'

RSpec.describe Hand, type: :model do
  let!(:player) { create(:player, blood_pool: 5000) }
  let!(:daimon) { create(:daimon, effect: 'None', progression_level: 0) }
  let(:game) { create(:game, player: player) }
  let(:round) { game.rounds.first }
  let(:hand) { round.hands.first }
  let!(:card_1) { create(:card, rank: "7", suit: "Hearts") }
  let!(:card_2) { create(:card, rank: "9", suit: "Spades") }
  let!(:ace_card) { create(:card, rank: "Ace", suit: "Diamonds") }

  ### ✅ Validations
  describe "Validations" do
    it "is valid with all required attributes" do
      expect(hand).to be_valid
    end

    it "is invalid without a hand_number" do
      hand.hand_number = nil
      expect(hand).not_to be_valid
    end
  end

  ### ✅ Callbacks: `initialize_hand`
  describe "Callbacks" do
    it "initializes player and daimon hands correctly" do
      new_hand = Hand.create!(round: round, hand_number: 1)
      expect(new_hand.player_hand.size).to eq(2)
      expect(new_hand.daimon_hand.size).to eq(1)
    end

    it "removes drawn cards from the deck" do
      shuffled_deck = [card_1.id, card_2.id, ace_card.id, 4, 5, 6]
      round.update!(shuffled_deck: shuffled_deck)

      new_hand = Hand.create!(round: round, hand_number: 1)

      expect(round.reload.shuffled_deck).not_to include(*new_hand.player_hand)
      expect(round.reload.shuffled_deck).not_to include(*new_hand.daimon_hand)
    end
  end

  describe "initialize_hand" do
    it "automatically deducts the correct wager when a hand is created" do
      allow(round).to receive(:calculate_wager).and_return(500)
  
      expect { create(:hand, round: round, hand_number: 1) }
        .to change { player.reload.blood_pool }.by(-500)
        .and change { round.reload.daimon_current_blood_pool }.by(-500)
    end
  end
  

  ### ✅ Player Actions: `draw_player_card`
  describe "#draw_player_card" do
    it "draws a card and updates the deck" do
      round.update!(shuffled_deck: [card_1.id, card_2.id, ace_card.id])

      expect { hand.draw_player_card }
        .to change { hand.reload.player_hand.size }.by(1)
        .and change { round.reload.shuffled_deck.size }.by(-1)

      expect(hand.player_hand).to include(card_1.id)
    end
  end

  ### ✅ Player Actions: `player_stand`
  describe "#player_stand" do
    it "draws Daimon cards until 17 or above" do
      high_cards = [card_1.id, card_2.id, ace_card.id, card_1.id, card_2.id]
      round.update!(shuffled_deck: high_cards)
      
      expect { hand.player_stand }
      .to change { hand.reload.daimon_hand.size }
      .from(1)
      .to be >= 2
    end
  end

  ### ✅ Hand Resolution: `hand_resolution`
  describe "#hand_resolution" do
    it "correctly rewards player when they win" do
      hand.update!(blood_wager: 1000)
      player.blood_pool = 3000

      hand.hand_resolution(:player)
      expect { hand.hand_resolution(:player) }
        .to change { player.reload.blood_pool }.by(1000)
        .and change { game.reload.total_hands_won }.by(1)

      expect(hand.winner).to eq("player")
    end

    it "correctly rewards Daimon when it wins" do
      hand.update!(blood_wager: 1000)
      round.daimon_current_blood_pool = 1000
      
      expect { hand.hand_resolution(:daimon) }
        .to change { round.daimon_current_blood_pool }.by(1000)
        .and change { game.reload.total_hands_lost }.by(1)

      expect(hand.winner).to eq("daimon")
    end

    it "correctly refunds in a push scenario" do
      hand.update!(blood_wager: 1000)

      expect { hand.hand_resolution(:push) }
        .to change { player.reload.blood_pool }.by(500)
        .and change { round.reload.daimon_current_blood_pool }.by(500)
        .and change { game.reload.total_hands_lost }.by(1)

      expect(hand.winner).to eq("push")
    end
  end

  ### ✅ Hand Logic: `hand_total`
  describe "#hand_total" do
    it "calculates total without Aces correctly" do
      hand.player_hand = [card_1.id, card_2.id] # 7 + 9 = 16
      expect(hand.hand_total(hand.player_hand)).to eq(16)
    end

    it "calculates Aces as 11 when possible" do
      hand.player_hand = [card_1.id, ace_card.id] # 7 + Ace = 18
      expect(hand.hand_total(hand.player_hand)).to eq(18)
    end

    it "calculates Aces as 1 when necessary" do
      hand.player_hand = [card_1.id, ace_card.id, card_2.id] # 7 + Ace + 9 = 17 (Ace as 1)
      expect(hand.hand_total(hand.player_hand)).to eq(17)
    end
  end

  ### ✅ Hand Logic: `hand_result?`
  describe "#hand_result?" do
    it "determines player win when Daimon busts" do
      allow(hand).to receive(:hand_total).with(hand.player_hand).and_return(18) # ✅ Stub player hand total
      allow(hand).to receive(:hand_total).with(hand.daimon_hand).and_return(22) # ✅ Stub Daimon bust

      expect(hand.hand_result?).to eq(:player)
    end

    it "determines Daimon win when it has a higher total" do
      allow(hand).to receive(:hand_total).with(hand.player_hand).and_return(18)
      allow(hand).to receive(:hand_total).with(hand.daimon_hand).and_return(19)

      expect(hand.hand_result?).to eq(:daimon)
    end

    it "determines a push when totals are equal" do
      allow(hand).to receive(:hand_total).with(hand.player_hand).and_return(20)
      allow(hand).to receive(:hand_total).with(hand.daimon_hand).and_return(20)

      expect(hand.hand_result?).to eq(:push)
    end
  end

  ### ✅ Hand Logic: `player_hand_bust?`
  describe "#player_hand_bust?" do
    it "returns true if player busts" do
      allow(hand).to receive(:hand_total).with(hand.player_hand).and_return(22)
      expect(hand.player_hand_bust?).to be true
    end

    it "returns false if player is under 21" do
      allow(hand).to receive(:hand_total).with(hand.player_hand).and_return(20)
      expect(hand.player_hand_bust?).to be false
    end
  end
end
