require 'rails_helper'

RSpec.describe Round, type: :model do
  let!(:player) { create(:player, blood_pool: 5000) }
  let!(:daimon) { create(:daimon, effect: 'none', progression_level: 0) }
  let(:game) { create(:game, player: player) }
  let(:round) { game.rounds.first }

  ### ✅ Validations
  describe "Validations" do
    it "is valid with all required attributes" do
      expect(round).to be_valid
    end

    it "is invalid without a round_number" do
      round.round_number = nil
      expect(round).not_to be_valid
    end

    it "is invalid with negative daimon health" do
      round.daimon_current_blood_pool = -10
      expect(round).not_to be_valid
    end

    it "is invalid if hand_counter is less than 1" do
      round.hand_counter = 0
      expect(round).not_to be_valid
    end
  end

  ### ✅ Callbacks: `initialize_round`, `start_first_hand`
  describe "Callbacks" do
    it "initializes round attributes correctly" do
      new_round = Round.create!(game: game, daimon: daimon, round_number: 1, hand_counter: 1)
      
      expect(new_round.daimon_max_blood_pool).to eq(new_round.calculate_daimon_health)
      expect(new_round.daimon_current_blood_pool).to eq(new_round.daimon_max_blood_pool - 500)
    end

    it "creates the first hand after the round is created" do
      expect(round.hands.count).to eq(1)
      expect { create(:round, game: game, daimon: daimon, round_number: 2) }.to change { Hand.count }.by(1)
    end
  end

  ### ✅ `calculate_daimon_health` Method
  describe "#calculate_daimon_health" do
    it "returns the correct base health at round 1" do
      expect(round.calculate_daimon_health).to eq(2500)
    end

    it "scales Daimon health for higher rounds" do
      high_round = create(:round, game: game, daimon: daimon, round_number: 5)
      expected_health = ((2500 * (1.155 ** 4))).to_i # 4 exponent since it's round 5
      expect(high_round.calculate_daimon_health).to eq(expected_health)
    end

    it "doubles health if the Daimon has the 'double_health' effect" do
      daimon.update!(effect: "double_health")
      expect(round.calculate_daimon_health).to eq(5000) # 2500 * 2
    end
  end

  ### ✅ `calculate_wager` Method
  describe "#calculate_wager" do
    it "returns 500 for hands before round 5" do
      round.update!(hand_counter: 4)
      expect(round.calculate_wager).to eq(500)
    end

    it "increases wager after hand 5" do
      round.update!(hand_counter: 6)
      expected_wager = 500 + (410 * (6 - 4))
      expect(round.calculate_wager).to eq(expected_wager)
    end
  end

  ### ✅ Deck Management
  describe "#reshuffle_if_empty" do
    it "calls RoundDeckService to reshuffle if the deck is empty" do
      deck_service = instance_double(RoundDeckService)
      allow(RoundDeckService).to receive(:new).with(round).and_return(deck_service)
      allow(deck_service).to receive(:reshuffle_if_empty)

      round.reshuffle_if_empty

      expect(deck_service).to have_received(:reshuffle_if_empty)
    end
  end

  describe "#update_shuffled_deck" do
    it "updates the shuffled deck correctly" do
      new_deck = [1, 2, 3, 4, 5]
      round.update_shuffled_deck(new_deck)
      expect(round.shuffled_deck).to eq(new_deck)
    end
  end

  ### ✅ Daimon Health Management
  describe "#update_daimon_health" do
    it "decreases Daimon's health correctly" do
      expect { round.update_daimon_health(-500) }
        .to change { round.reload.daimon_current_blood_pool }.by(-500)
    end

    it "does not decrease below zero" do
      expect { round.update_daimon_health(-999999) }
        .to change { round.reload.daimon_current_blood_pool }.to(0)
    end

    it "does not increase above max health" do
      round.update!(daimon_current_blood_pool: 2000)
      expect { round.update_daimon_health(5000) }
        .to change { round.reload.daimon_current_blood_pool }.to(round.daimon_max_blood_pool)
    end

    it "does not update if the amount is zero" do
      expect { round.update_daimon_health(0) }
        .not_to change { round.reload.daimon_current_blood_pool }
    end
  end

  ### ✅ Round Completion Check
  describe "#round_over?" do
    it "returns false if the round is still active" do
      expect(round.round_over?).to be false
    end

    it "updates winner to daimon and returns true when player has no blood" do
      player.update!(blood_pool: 0)
      expect(round.round_over?).to be true
      expect(round.reload.winner).to eq("daimon")
    end

    it "updates winner to player and returns true when Daimon has no blood" do
      round.update!(daimon_current_blood_pool: 0)
      expect(round.round_over?).to be true
      expect(round.reload.winner).to eq("player")
    end

    it "does not update winner if the round is not over" do
      expect { round.round_over? }.not_to change { round.reload.winner }
    end
  end
end
