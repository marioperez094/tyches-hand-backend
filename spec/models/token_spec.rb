require 'rails_helper'

RSpec.describe Token, type: :model do
  describe 'Validations' do
    let(:token) { build(:token) }

    context 'basic attributes' do
      it 'is valid with all attributes' do
        expect(token).to be_valid
      end

      it 'is invalid without a name' do
        token.name = nil
        expect(token).not_to be_valid
      end
  
      it 'requires a unique name' do
        create(:token, name: 'Eye of Tyche')
        duplicate_token = build(:token, name: 'Eye of Tyche', story_sequence: 2)
        expect(duplicate_token).not_to be_valid
      end

      it 'is invalid without a rune' do
        token.rune = nil
        expect(token).not_to be_valid
      end
  
      it 'requires a unique rune' do
        create(:token, rune: 'T')
        duplicate_token = build(:token, rune: 'T', story_sequence: 2)
        expect(duplicate_token).not_to be_valid
      end

      it 'is invalid without a description' do
        token.description = nil
        expect(token).not_to be_valid
      end
      
      it 'is invalid without story_token' do
        token.story_token = nil
        expect(token).not_to be_valid
      end

      it "is valid without story_sequence if it's not a story_token" do
        token.story_token = false
        token.story_sequence = nil
        expect(token).to be_valid
      end

      it "is invalid without story_sequence if it's a story_token" do
        token.story_token = true
        token.story_sequence = nil
        expect(token).not_to be_valid
      end

      context 'slot effect_type' do  
        [
          :inscribed_effect_type,
          :oathbound_effect_type,
          :offering_effect_type
        ].each do |field|
          it "requires #{field} to be present" do
            token.send("#{field}=", nil)
            expect(token).not_to be_valid
            expect(token.errors[field]).to include("can't be blank")
          end

          it "requires #{field} to be a valid effect_type" do
            token.send("#{field}=", 'stars_and_rainbows')
            expect(token).not_to be_valid
            expect(token.errors[field]).to include('is not included in the list')
          end
        end
      end
    end
  end

  describe 'Associations' do
    let(:token) { create(:token) }
    let(:player) { create(:player) }
    let(:slot) { player.inscribed_slot }

    it 'has a collection and deletes it when destroyed' do
      token.players << player
      expect { token.destroy }.to change { TokenCollection.count }.by(-1)
    end
  end

  describe 'Scopes' do
    let(:player) { create(:player) }
    let(:story_token_1) { create(:token, story_token: true, story_sequence: 0) }
    let(:story_token_2) { create(:token, name: 'Ear of Tyche', rune: 'I', story_token: true, story_sequence: 1) }
    let(:discovered_token) { create(:token, name: 'Damage of Tyche', rune: 'F') }
    let(:undiscovered_token) { create(:token, name: 'Heal of Tyche', rune: 'S') }

    it 'story_tokens returns only story tokens in order' do
      expect(Token.story_tokens).not_to eq([story_token_2, story_token_1])
      expect(Token.story_tokens).to eq([story_token_1, story_token_2])
    end

    context '#by_undiscovered' do
      it 'by_undiscovered returns all tokens' do
        undiscovered_tokens = Token.by_undiscovered(player)
        expect(undiscovered_tokens).to contain_exactly(story_token_1, story_token_2, discovered_token, undiscovered_token)
      end

      it 'returns only undiscovered tokens' do
        player.tokens << story_token_1
        
        undiscovered_tokens = Token.by_undiscovered(player)
        expect(undiscovered_tokens).to contain_exactly(story_token_2, discovered_token, undiscovered_token)
      end

      it 'returns an empty result fo undiscovered tokens' do
        player.tokens << [story_token_1, story_token_2, discovered_token, undiscovered_token]
        
        undiscovered_tokens = Token.by_undiscovered(player)
        expect(undiscovered_tokens).to be_empty
      end
    end
  end

  describe 'Instance Methods' do
    let!(:story_token_1) { create(:token, story_token: true, story_sequence: 0) }
    let!(:story_token_2) { create(:token, name: 'Ear of Tyche', rune: 'I', story_token: true, story_sequence: 1) }

    describe '#next_story_token' do
      it ".next_story_token returns the next lore token based on progression" do
        expect(Token.next_story_token(0)).to eq(story_token_1)
        expect(Token.next_story_token(1)).to eq(story_token_2)
      end

      it ".next_story_token returns nil if no lore token is left" do
        expect(Token.next_story_token(2)).to be_nil
      end
    end
  end
end