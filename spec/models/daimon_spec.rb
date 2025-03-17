require 'rails_helper'

RSpec.describe Daimon, type: :model do
  let(:player) { create(:player, lore_progression: 1) } # Simulating a player with lore progression level 1
  let!(:daimon_1) { create(:daimon, progression_level: 0, name: "The Whisper", rune: 'T', effect: 'double_wager', taunts: ["Try harder!", "You can't win!"]) }
  let!(:daimon_2) { create(:daimon, progression_level: 1, name: "The Thrill", rune: 'I', effect: 'avoid_bust') }
  let!(:daimon_3) { create(:daimon, progression_level: 2, name: "The Pull", effect: 'double_health') }

  ### ✅ Validations
  describe "Validations" do
    it "is valid with all attributes" do
      expect(daimon_1).to be_valid
    end

    it "is invalid without a name" do
      daimon_1.name = nil
      expect(daimon_1).not_to be_valid
    end

    it "is invalid with a duplicate name" do
      new_daimon = build(:daimon, name: "The Whisper")
      expect(new_daimon).not_to be_valid
    end

    it "is invalid without an effect_type" do
      daimon_1.effect_type = nil
      expect(daimon_1).not_to be_valid
    end

    it "requires an effect type from the EFFECT_TYPES list" do
      valid_daimon = build(:daimon, progression_level: 3, rune: 'J', name: 'The Trickster', effect_type: "Damage")
      invalid_daimon = build(:daimon, progression_level: 4, rune: 'E', name: 'The Obsession', effect_type: 'InvalidType')

      expect(valid_daimon).to be_valid
      expect(invalid_daimon).not_to be_valid
    end

    it "is invalid without a rune" do
      daimon_1.rune = nil
      expect(daimon_1).not_to be_valid
    end

    it "is invalid without an intro dialogue" do
      daimon_1.intro = nil
      expect(daimon_1).not_to be_valid
    end

    it "is invalid without a player_win dialogue" do
      daimon_1.player_win = nil
      expect(daimon_1).not_to be_valid
    end

    it "is invalid without a player_lose dialogue" do
      daimon_1.player_lose = nil
      expect(daimon_1).not_to be_valid
    end

    it "is invalid with a negative progression_level" do
      daimon_1.progression_level = -1
      expect(daimon_1).not_to be_valid
    end
  end

  ### ✅ Scope: by_unlocked
  describe "Scope: by_unlocked" do
    it "returns Daimons that the player has unlocked" do
      unlocked_daimons = Daimon.by_unlocked(player)
      expect(unlocked_daimons).to include(daimon_1, daimon_2)
      expect(unlocked_daimons).not_to include(daimon_3)
    end
  end

  ### ✅ Random Taunt Functionality
  describe "#random_taunt" do
    it "returns a random taunt from the JSON array" do
      expect(daimon_1.taunts).to include(daimon_1.random_taunt)
    end

    it "returns '...' if no taunts exist" do
      daimon_1.taunts = []
      expect(daimon_1.random_taunt).to eq("...")
    end
  end

  ### ✅ Next Available Daimon
  describe ".next_available_daimon" do
    context "when a Daimon exists for the given progression level" do
      it "returns the correct Daimon for progression level 0" do
        expect(Daimon.next_daimon(0)).to eq(daimon_1)
      end

      it "returns the correct Daimon for progression level 1" do
        expect(Daimon.next_daimon(1)).to eq(daimon_2)
      end

      it "returns the correct Daimon for progression level 2" do
        expect(Daimon.next_daimon(2)).to eq(daimon_3)
      end
    end

    context "when no Daimon exists for the given progression level" do
      it "returns nil if no Daimon matches the given progression level" do
        expect(Daimon.next_daimon(3)).to be_nil
      end
    end
  end
end
