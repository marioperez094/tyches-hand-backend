require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'Validations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { build(:game, player: player) }

    context 'basic attributes' do
      it 'is valid with daimon progress, rounds played, status, and player hand stats' do
        expect(game).to be_valid
      end

      it 'is invalid without daimon_progress' do
        game.daimon_progress = nil
        expect(game).not_to be_valid
      end

      it 'requires daimon_progress to be a number' do
        game.daimon_progress = 'String'
        expect(game).not_to be_valid
      end

      it 'requires daimon_progress to be greater than or equal to -1' do
        game.daimon_progress = -2
        expect(game).not_to be_valid
      end

      it 'is invalid without a status' do
        game.status = nil
        expect(game).not_to be_valid
      end

      it 'is invalid with an incorrect status' do
        expect { game.status = :win }.to raise_error(ArgumentError)
      end
    end

    context 'numeric fields greater than -1' do
      [
        :rounds_played,
        :total_hands_won,
        :total_hands_lost,
        :win_streak,
        :longest_win_streak
      ].each do |field|
        it "requires #{field} to be present" do
          game.send("#{field}=", nil)
          expect(game).not_to be_valid
          expect(game.errors[field]).to include("can't be blank")
        end

        it "requires #{field} to be a number" do
          game.send("#{field}=", 's')
          expect(game).not_to be_valid
          expect(game.errors[field]).to include('is not a number')
        end

        it "requires #{field} to be greater than or equal to 0" do
          game.send("#{field}=", -1)
          expect(game).not_to be_valid
          expect(game.errors[field]).to include('must be greater than or equal to 0')
        end
      end
    end

    context 'longest_win_streak_must_be_greater_or_equal' do
      it 'is invalid if longest_win_streak is less than win_streak' do
        game.longest_win_streak = 2
        game.win_streak = 3
        expect(game).not_to be_valid
      end

      it 'is valid if longest_win_streak is greater than win_streak' do
        game.longest_win_streak = 3
        game.win_streak = 2
        expect(game).to be_valid
      end
      
      it 'is valid if longest_win_streak is equal to win_streak' do
        game.longest_win_streak = 2
        game.win_streak = 2
        expect(game).to be_valid
      end
    end
  end

  describe 'Associations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player) }
    let!(:round) { game.round }

    it 'belongs to a player' do
      expect(game.player).to eq(player)
    end

    it 'has a round and destroys when deleted' do
      expect(game.round).to eq(round)
      expect { game.destroy }.to change { Round.count }.by(-1)
    end
  end

  describe 'Instance Methods' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    
    context 'create_new_round' do
      let!(:game) { create(:game, player: player) }
      let!(:round) { game.round }
      
      it 'does not create a new round if the game has a round' do
        expect { game.create_new_round }.to raise_error('A round is already active.')
        expect(game.round.id).to eq(round.id)
      end

      it 'does not create a new round if the game is lost' do
        round.update!(status: :won)
        game.update!(status: :lost)

        expect { game.create_new_round }.to raise_error('Game must be in progress to start a new round.')
        expect(round.status).to eq('won')
        expect(game.round.id).to eq(round.id)
      end

      it 'it creates a new round' do
        round.update!(status: :won)
        game.create_new_round
        new_round = game.round

        expect(new_round.id).to eq(2)
        expect(new_round).not_to be(round)
      end
    end

    context '#advance_daimon' do
      let(:game) { create(:game, player: player) }

      it 'does not update daimon_progress if player.story_progression is not greater' do
        game.update!(daimon_progress: 1)
        player.update!(story_progression: 1)

        expect { game.advance_daimon }.not_to change { game.reload.daimon_progress }
      end

      it 'updates daimon_progress if player has progressed the story' do
        game.update!(daimon_progress: 1)
        player.update!(story_progression: 2)

        expect { game.advance_daimon }.to change { game.reload.daimon_progress }.from(1).to(2)
      end
    end
    describe 'hand stats methods' do
      let(:game) { create(:game, player: player) }
    
      context '#record_hand_loss' do
        it 'increments total_hands_lost and resets win streak' do
          game.update!(win_streak: 5, longest_win_streak: 6)

          expect { game.record_hand_loss }.to change { game.reload.total_hands_lost }.by(1).and change { game.reload.win_streak }.to(0)
        end

        it "does not go negative when win streak is already zero" do
          game.update!(win_streak: 0)
    
          expect { game.record_hand_loss }.not_to change { game.reload.win_streak }
          expect(game.win_streak).to eq(0)
        end
      end

      context '#record_hand_win' do
        it "increments total_hands_won and updates win streak" do
          expect { game.record_hand_win }.to change { game.reload.total_hands_won }.by(1).and change { game.reload.win_streak }.by(1)
        end
  
        it "updates longest_win_streak if win_streak exceeds it" do
          game.update!(win_streak: 2, longest_win_streak: 2)
  
          expect { game.record_hand_win }.to change { game.reload.longest_win_streak }.from(2).to(3)
        end
  
        it "does not update longest_win_streak if win_streak is lower" do
          game.update!(win_streak: 3, longest_win_streak: 5)
  
          expect { game.record_hand_win }.not_to change { game.reload.longest_win_streak }
        end
  
        it "does not exceed integer limits for longest_win_streak" do
          game.update!(win_streak: 9999, longest_win_streak: 9999)
  
          expect { game.record_hand_win }.to change { game.reload.longest_win_streak }.by(1)
          expect(game.longest_win_streak).to eq(10000)
        end
      end

      context 'create_new_round' do
        it 'raises an error if the game is lost' do
          game.update!(status: :lost)

          expect { game.create_new_round }.to raise_error('Game must be in progress to start a new round.')
        end

        it 'raises an error if a round is active' do
          expect { game.create_new_round }.to raise_error('A round is already active.')
        end

        it 'creates a new round' do
          round_id = game.round.id
          game.round.update!(status: :won)

          expect { game.create_new_round }.to change { Round.count }.by(0)
          expect(game.reload.rounds_played).to eq(2)
          expect(game.round.id).not_to eq(round_id)
        end
      end
    end
  end

  describe 'Round replacement' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:second_daimon) { create(:daimon, name: 'The Wire', rune: 'T', effect_type: 'increase_max_health', story_sequence: 1) }
    let(:game) { create(:game, player: player) }
    let!(:old_round) { game.round || create(:round, game: game, daimon: daimon) }

    it 'destroys the old round and assigns the new round' do
      expect(game.round).to eq(old_round)

      old_round.destroy
      new_round = create(:round, game: game, daimon_blood_pool: 5000, daimon_max_blood_pool: 5000, daimon: second_daimon) 
      expect(game.reload.round).to eq(new_round)
      expect(game.round).not_to eq(old_round)
    end
  end
end