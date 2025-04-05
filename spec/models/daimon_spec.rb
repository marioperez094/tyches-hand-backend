require 'rails_helper'

RSpec.describe Daimon, type: :model do
  let(:daimon) { build(:daimon) }

  describe "Validations" do
    it "is valid with all attributes" do
      expect(daimon).to be_valid
    end

    it "is invalid without a name" do
      daimon.name = nil
      expect(daimon).not_to be_valid
    end

    it "is invalid with a duplicate name" do
      create(:daimon, name: 'The Whisper')
      duplicate_daimon = build(:daimon, name: "The Whisper", story_sequence: 1)
      expect(duplicate_daimon).not_to be_valid
    end
    
    it 'is invalid with a duplicate rune' do
      create(:daimon, rune: 'T')
      duplicate_token = build(:token, rune: 'T', story_sequence: 1)
      expect(duplicate_token).not_to be_valid
    end
    
    it "is invalid without a description" do
      daimon.description = nil
      expect(daimon).not_to be_valid
    end

    it "is invalid without an effect_type" do
      daimon.effect_type = nil
      expect(daimon).not_to be_valid
    end

    it "requires a valid effect_type" do
      daimon.effect_type = 'stars_and_rainbows'
      expect(daimon).not_to be_valid
    end

    it "is invalid without an intro dialogue" do
      daimon.intro = nil
      expect(daimon).not_to be_valid
    end

    it "is invalid without a player_win dialogue" do
      daimon.player_win = nil
      expect(daimon).not_to be_valid
    end

    it "is invalid without a player_lose dialogue" do
      daimon.player_lose = nil
      expect(daimon).not_to be_valid
    end

    it 'is invalid without in game dialogue' do
      daimon.dialogue = nil
      expect(daimon).not_to be_valid
    end

    it "is invalid with a negative progression_level" do
      daimon.story_sequence = -1
      expect(daimon).not_to be_valid
    end
  end

  describe 'Associations' do
    let!(:daimon) { create(:daimon) }
    let!(:player) { create(:player) }
    let!(:game) { create(:game, player: player) }

    it 'has many rounds and deletes it when destroyed' do
      expect(game.round.daimon).to eq(daimon)
      expect{ daimon.destroy }.to change { Round.count }.by(-1)
    end
  end

  describe 'Scopes' do
    let!(:discovered_daimon) { create(:daimon, story_sequence: 0) }
    let!(:undiscovered_daimon) { create(:daimon, name: 'The Draw', rune: 'T', effect_type: 'increase_max_health', story_sequence: 1) }
    let!(:player) { create(:player) }

    it 'by_unlocked returns only unlocked daimons' do
      expect(Daimon.by_unlocked(player)).not_to include(undiscovered_daimon)
      expect(Daimon.by_unlocked(player)).to include(discovered_daimon)
    end

    it 'returns all unlocked daimons' do
      player.story_progression = 1
      
      expect(Daimon.by_unlocked(player)).not_to eq([undiscovered_daimon, discovered_daimon])
      expect(Daimon.by_unlocked(player)).to eq([discovered_daimon, undiscovered_daimon])
    end
  end

  describe 'Instance Methods' do
    let!(:daimon_1) { create(:daimon, story_sequence: 0) }
    let!(:daimon_2) { create(:daimon, name: 'The Draw', rune: 'T', effect_type: 'increase_max_health', story_sequence: 1) }
    
    describe '#next_daimon' do
      it ".next_story_token returns the next lore token based on progression" do
        expect(Daimon.next_daimon(0)).to eq(daimon_1)
        expect(Daimon.next_daimon(1)).to eq(daimon_2)
      end

      it ".next_story_token returns nil if no lore token is left" do
        expect(Daimon.next_daimon(2)).to be_nil
      end
    end

    describe '#daimon_dialogue' do
      it '.dialogue returns a random line of dialogue' do
        dialogue = daimon.daimon_dialogue
        expect(daimon.dialogue).to include(dialogue)
      end

      it "returns '...' if no taunts exist" do
        daimon.dialogue = []
        expect(daimon.daimon_dialogue).to eq("...")
      end
    end
  end
end
