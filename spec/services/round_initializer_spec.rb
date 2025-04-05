require 'rails_helper'

RSpec.describe RoundInitializer do
  let(:player) { create(:player, story_progression: 0) }
  let(:slot) { player.inscribed_slot }
  let(:inscribed_buff_token) { create( :token, name: 'increase_max_health', rune: '1', inscribed_effect_type: 'increase_max_health', 
    inscribed_effect_values: { 'player_max_health' => {
      'value' => 1.2,
      'apply_on_phase' => 'round_start'
    }})}
  let(:inscribed_debuff_token) { create(:token, name: 'decrease_max_health', rune: '2', inscribed_effect_type: 'decrease_max_health', 
    inscribed_effect_values: { 'player_max_health' => {
      'value' => 0.2,
      'apply_on_phase' => 'round_start'
    }})}
  let(:inscribed_daimon_token) { create(:token, name: 'decrease_daimon_max_health', rune: '3', inscribed_effect_type: 'decrease_daimon_max_health', 
    inscribed_effect_values: { 'daimon_max_health' => {
      'value' => 0.8,
      'apply_on_phase' => 'round_start'
    }})}
  
  def subject(game)
    described_class.new(game).call
  end

  before do
    player.tokens << [inscribed_buff_token, inscribed_debuff_token, inscribed_daimon_token]
  end
  
  describe '#calculate_daimon_health' do
    context 'when daimon has no buffs' do
      let!(:daimon) { create(:daimon) }

      it 'gives the base daimon health' do
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.reload.round.daimon_max_blood_pool).to eq(2500)
      end

      it 'gives a debuffed daimon health' do
        collection = player.token_collections.find_by(token: inscribed_daimon_token)
        slot.create_equipped_token!(token_collection: collection)
        
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.daimon_max_blood_pool).to eq((2500 * 0.8).to_i)
      end
    end
    
    context 'when daimon has buffs' do
      let!(:daimon) { create(:daimon, effect_type: 'increase_daimon_max_health', effect_values: { 'daimon_max_health' =>
        {
          'value' => 2,
          'apply_on_phase' => 'round_start'
        }})}

      it 'gives double the daimon health' do
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.reload.round.daimon_max_blood_pool).to eq((2500 * 2).to_i)
      end

      it 'gives a debuffed doubled daimon health' do
        collection = player.token_collections.find_by(token: inscribed_daimon_token)
        slot.create_equipped_token!(token_collection: collection)
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.daimon_max_blood_pool).to eq((2500 * 2 * 0.8).to_i)
      end
    end
  end

  describe '#max_blood_pool' do
    context 'when daimon has no buffs' do
      let!(:daimon) { create(:daimon) }

      it 'gives the base player health' do
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.player_max_blood_pool).to eq(5000)
      end

      it 'gives a buffed player health' do
        collection = player.token_collections.find_by(token: inscribed_buff_token)
        slot.create_equipped_token!(token_collection: collection)
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.player_max_blood_pool).to eq((5000 + 1000).to_i)
      end

      it 'gives a debuffed player health' do
        collection = player.token_collections.find_by(token: inscribed_debuff_token)
        slot.create_equipped_token!(token_collection: collection)
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.player_max_blood_pool).to eq((5000 * 0.2).to_i)
      end
    end

    context 'when daimon has a debuff' do
      let!(:daimon) { create(:daimon, effect_type: 'decrease_max_health', effect_values: { 'player_max_health' => {
        'value' => 0.9,
        'apply_on_phase' => 'round_start'
      }})}

      it 'gives the base player health' do
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)
        expect(game.round.player_max_blood_pool).to eq((5000 * 0.9).to_i)
      end

      it 'gives a buffed player health' do
        collection = player.token_collections.find_by(token: inscribed_buff_token)
        slot.create_equipped_token!(token_collection: collection)
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.player_max_blood_pool).to eq(((5000 * 0.9) * 1.2).to_i)
      end

      it 'gives a debuffed player health' do
        collection = player.token_collections.find_by(token: inscribed_debuff_token)
        slot.create_equipped_token!(token_collection: collection)
        game = create(:game, player: player, rounds_played: 0, daimon_progress: 0)

        expect(game.round.player_max_blood_pool).to eq(((5000 * 0.9) * 0.2).to_i)
      end
    end
  end

  describe '#set_daimon' do
    let!(:first_daimon) { create(:daimon, story_sequence: 0) }
    let!(:second_daimon) { create(:daimon, name: 'The Wire', rune: 'W', effect_type:'increase_daimon_max_health', story_sequence: 1) }
    let!(:game) { create(:game, player: player, daimon_progress: -1)}
    
    context 'when player begins' do
      it 'returns the first daimon in the sequence' do
        initializer = described_class.new(game)
        daimon = initializer.send(:set_daimon)

        expect(game.daimon_progress).to eq(-1)
        expect(daimon).to eq(first_daimon)
      end
    end

    context 'when the player advances the story' do
      it 'returns the next daimon in the sequence' do
        game.update!(daimon_progress: 0)
        player.update!(story_progression: 1)

        
        initializer = described_class.new(game)
        daimon = initializer.send(:set_daimon)

        expect(game.daimon_progress).to eq(0)
        expect(daimon).to eq(second_daimon)
      end
    end

    context 'when the player picks a non-story token' do
      it 'returns a random daimon' do
        game.update!(daimon_progress: 1)
        player.update!(story_progression: 1)

        
        initializer = described_class.new(game)
        chosen_daimons = 10.times.map { initializer.send(:set_daimon) }.uniq
        expect(chosen_daimons).to contain_exactly(first_daimon, second_daimon)
      end
    end
  end

  describe '#initialize_round' do
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player, rounds_played: 0, daimon_progress: 0) }
    let!(:round) { game.round }
    
    context 'when round exists and winner is chosen' do

      it 'destroys the existing round and creates a new one' do
        expect(Round.count).to eq(1)
        expect(game.rounds_played).to eq(1)

        game.round.update!(status: :won)

        expect{ subject(game) }.to change { Round.count }.by(0)
        expect(game.reload.round).not_to eq(round)
      end
    end

    context 'when round exists and is in progress' do
      it 'does not destroy the existing round' do
        expect(Round.count).to eq(1)

        expect{ subject(game) }.to raise_error('A round is already active.')
        expect(game.rounds_played).to eq(1)
        expect(game.reload.round).to eq(round)
      end
    end

    context 'when game is lost and round is over' do
      it 'does not create a new round' do
        game.round.update!(status: :won)
        game.update!(status: :lost)
        
        expect{ game.create_new_round }.to raise_error('Game must be in progress to start a new round.')

        expect(game.reload.rounds_played).to eq(1)
        expect(game.reload.round).to eq(round)
      end
    end
  end
end