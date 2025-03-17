require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:player) { create(:player, lore_progression: 0) }
  let!(:daimon_1) { create(:daimon, progression_level: 0) }
  let!(:daimon_2) { create(:daimon, progression_level: 1, name: 'The Hype', rune: "O", effect: 'no_bust') }
  let(:game) { create(:game, player: player, story_daimon_progress: -1, current_round: 1) }

  ### ✅ Validations
  describe "Validations" do
    it "is valid with all required attributes" do
      expect(game).to be_valid
    end

    it "is invalid without story_daimon_progress" do
      game.story_daimon_progress = nil
      expect(game).not_to be_valid
    end

    it "is invalid with a negative current_round" do
      game.current_round = -1
      expect(game).not_to be_valid
    end

    it "is invalid if longest_win_streak is less than win_streak" do
      game.longest_win_streak = 2
      game.win_streak = 3
      expect(game).not_to be_valid
    end
  end

  ### ✅ Callbacks: `start_first_round`
  describe "Callbacks" do
    it "creates the first round after the game is created" do
      expect { create(:game, player: player) }.to change { Round.count }.by(1)
    end
  end

  ### ✅ `set_daimon` Method (Updated)
  describe "#set_daimon" do
    context "when story_daimon_progress matches player.lore_progression" do
      it "randomly picks between daimon_1 and daimon_2" do
        allow(Daimon).to receive(:by_unlocked).with(player).and_return([daimon_1, daimon_2])
  
        game.update!(story_daimon_progress: 0) # Ensure progress matches
        player.update!(lore_progression: 0)
  
        chosen_daimons = 10.times.map { game.set_daimon }.uniq # Run 10 times to check randomness
        expect(chosen_daimons).to contain_exactly(daimon_1, daimon_2) # ✅ Ensures both are chosen
      end
    end

    context "when player progresses in the story" do
      it "calls advance_daimon and updates story_daimon_progress before returning the next Daimon" do
        game.update!(story_daimon_progress: -1) # Explicitly reset before the test
        player.update!(lore_progression: 1) # Ensure the player progresses
        daimon = game.set_daimon

        expect(game.story_daimon_progress).to eq(1)
        expect(daimon).to eq(daimon_2)
      end
    end
  end

  ### ✅ `advance_daimon` Method
  describe "#advance_daimon" do
    it "does not update story_daimon_progress if player.lore_progression is not greater" do
      game.update!(story_daimon_progress: 1)
      player.update!(lore_progression: 1)

      expect { game.advance_daimon }.not_to change { game.reload.story_daimon_progress }
    end

    it "updates story_daimon_progress if player has progressed further" do
      game.update!(story_daimon_progress: 0)
      player.update!(lore_progression: 2)

      expect { game.advance_daimon }.to change { game.reload.story_daimon_progress }.from(0).to(2)
    end
  end

  ### ✅ `record_hand_win` & `record_hand_loss` Methods
  describe "#record_hand_win" do
    it "increments total_hands_won and updates win streak" do
      expect { game.record_hand_win }.to change { game.reload.total_hands_won }.by(1)
        .and change { game.reload.win_streak }.by(1)
    end

    it "updates longest_win_streak if win_streak exceeds it" do
      game.update!(win_streak: 2, longest_win_streak: 2)

      expect { game.record_hand_win }.to change { game.reload.longest_win_streak }.from(2).to(3)
    end
  end

  describe "#record_hand_loss" do
    it "increments total_hands_lost and resets win streak" do
      game.update!(win_streak: 5, longest_win_streak: 6)

      expect { game.record_hand_loss }.to change { game.reload.total_hands_lost }.by(1)
        .and change { game.reload.win_streak }.to(0)
    end
  end
end
