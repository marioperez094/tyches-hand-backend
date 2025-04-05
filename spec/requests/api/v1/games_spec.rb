require 'rails_helper'

RSpec.describe "Api::V1::Games", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  let!(:player) { create(:player) }
  let!(:daimon) { create(:daimon, story_sequence: 0) }
  let!(:play_token) { create(:token) }
  let(:token) { JsonWebToken.encode(player_id: player.id) }

  def player_slots
    player.slots.map do |slot|
      slot_hash = {
        'id' => slot.id,
        'slot_type' => slot.slot_type
      }
  
      if slot.equipped_token&.token_collection&.token
        token = slot.equipped_token.token_collection.token
        slot_hash['token'] = {
          'id' => token.id,
          'name' => token.name,
          'description' => token.description,
          'rune' => token.rune
        }
      end
  
      slot_hash
    end
  end  

  describe 'POST #create' do
    context 'game exists' do
      let!(:game) { create(:game, player: player) }
      it 'does not create a new game if the player has a game in progress' do          
        post '/api/v1/games', headers: { 'Authorization' => token }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('A game is already active.')
      end
      
      it 'creates a new game with a new round if the player has lost the previous game' do
        player.increment!(:games_played)
        game.update!(status: :lost)
        
        post '/api/v1/games', headers: { 'Authorization' => token }

        expect(player.reload.game.id).to eq(2)  
        expect(player.reload.games_played).to eq(2)
        expect(Round.count).to eq(1)

        show_game = json_response
        expect(show_game['daimon']['name']).to eq(player.game.round.daimon.name)
        expect(show_game['daimon']['blood_pool']).to eq(player.game.round.daimon_blood_pool)
        expect(show_game['daimon']['effect_type']).to eq(player.game.round.daimon.effect_type)
        expect(show_game['daimon']['intro']).to include(player.game.round.daimon.intro)
        expect(show_game['daimon']['max_blood_pool']).to eq(player.game.round.daimon_max_blood_pool)
        expect(show_game['daimon']['rune']).to eq(player.game.round.daimon.rune)

        expect(show_game['player']['username']).to eq(player.username)
        expect(show_game['player']['blood_pool']).to eq(player.reload.blood_pool)
        expect(show_game['player']['games_played']).to eq(player.games_played)
        expect(show_game['player']['max_blood_pool']).to eq(player.game.round.player_max_blood_pool)
        expect(show_game['player']['slots']).to eq(player_slots)
        expect(show_game['player']['tutorial_finished']).to eq(player.tutorial_finished)

        expect(show_game['round']['status']).to eq('in_progress')
      end
    end

    context 'no previous game' do
      before do
        collection = player.token_collections.create!(token: play_token)
        EquippedToken.create!(slot_id: player.inscribed_slot.id, token_collection_id: collection.id)
      end

      it 'creates a new game with a new round if the player has no previous game' do
        expect {
          post '/api/v1/games', headers: { 'Authorization' => token }
        }.to change(Game, :count).by(1)

        expect(player.reload.games_played).to eq(1)
        expect(Round.count).to eq(1)

        show_game = json_response
        expect(show_game['daimon']['name']).to eq(player.game.round.daimon.name)
        expect(show_game['daimon']['blood_pool']).to eq(player.game.round.daimon_blood_pool)
        expect(show_game['daimon']['effect_type']).to eq(player.game.round.daimon.effect_type)
        expect(show_game['daimon']['intro']).to include(player.game.round.daimon.intro)
        expect(show_game['daimon']['max_blood_pool']).to eq(player.game.round.daimon_max_blood_pool)
        expect(show_game['daimon']['rune']).to eq(player.game.round.daimon.rune)

        expect(show_game['player']['username']).to eq(player.username)
        expect(show_game['player']['blood_pool']).to eq(player.reload.blood_pool)
        expect(show_game['player']['games_played']).to eq(player.games_played)
        expect(show_game['player']['max_blood_pool']).to eq(player.game.round.player_max_blood_pool)
        expect(show_game['player']['slots']).to eq(player_slots)
        expect(show_game['player']['tutorial_finished']).to eq(player.tutorial_finished)

        expect(show_game['round']['status']).to eq('in_progress')
      end
      #it 'creates a new game if the player does not have a game and returns round info' do
        #player.game.destroy

        #expect {
          #post '/api/v1/games', headers: { 'Authorization' => token }
        #}.to change(Game, :count).by (1)
        #expect(Round.count).to be(1)
        
        #show_game = json_response['round']
        #expect(show_game['current_round']).to eq(game.current_round)
        #expect(show_game['hand_counter']).to eq(game.round.hand_counter)
        
        #show_daimon = show_game['daimon']
        #expect(show_daimon['daimon_max_blood_pool']).to eq(game.round.daimon_max_blood_pool)
        #expect(show_daimon['effect_type']).to eq(game.round.daimon.effect_type)
        #expect(show_daimon['name']).to eq(game.round.daimon.name)
      #end
    
      #it 'does not creates a new game if the player has a game in progress' do
        #expect {
          #post '/api/v1/games', headers: { 'Authorization' => token }
        #}.to change(Game, :count).by (0)
        #expect(player.game.id).to eq(game.id)
        #expect(Round.count).to be(1)
      #end

      #it 'creates a new game if the old game is lost' do
        #game.update!(status: :lost)

        #post '/api/v1/games', headers: { 'Authorization' => token }

        #player.reload
        #expect(player.game.id).not_to eq(game.id)
        #expect(player.game.round.id).not_to eq(game.round.id)
      #end
    end
  end
  
  #describe 'Get #show_player_stats' do
    #it 'returns the current player game stats' do
      #get '/api/v1/games/show_player_stats', headers: { 'Authorization' => token }
      #expect(response).to have_http_status(:ok)

      #show_game = json_response['game']
      #expect(show_game['games_played']).to eq(game.player.games_played)
      #expect(show_game['total_hands_won']).to eq(game.total_hands_won)
      #expect(show_game['total_hands_lost']).to eq(game.total_hands_lost)
      #expect(show_game['win_streak']).to eq(game.win_streak)
      #expect(show_game['longest_win_streak']).to eq(game.longest_win_streak)
    #end
  #end
end
