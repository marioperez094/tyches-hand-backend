require 'rails_helper'

RSpec.describe 'Api::V1::Players', type: :request do
  let(:json_response) { JSON.parse(response.body) }
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) { { username: 'testuser', password: 'password', password_confirmation: 'password' } }

      it 'creates a new player and returns a token' do
        expect {
          post '/api/v1/players', params: { player: valid_attributes }
        }.to change(Player, :count).by (1)
        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be_truthy
        expect(json_response).to have_key('token')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { username: '', password: 'password', password_confirmation: 'password' } }

      it 'does not create a new player and returns errors' do
        expect {
          post '/api/v1/players', params: { player: invalid_attributes }
        }.not_to change(Player, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end
    end
  end

  describe 'POST #login' do
  let(:player) { FactoryBot.create(:player, password: "password123", password_confirmation: "password123") }
  let(:valid_params) { { player: { username: player.username, password: "password123" } } }
  let(:invalid_params) { { player: { username: player.username, password: "wrongpassword" } } }

    context 'with valid credentials' do
      it 'returns a token' do
        post '/api/v1/players/login', params: { player: { username: player.username, password: player.password } }
        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be_truthy
        expect(json_response).to have_key('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post '/api/v1/players/login', params: { player: { username: player.username, password: 'wrongpassword' } }
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid username or password.')
      end

      it 'returns not found if player does not exist' do
        post '/api/v1/players/login', params: { player: { username: 'nonexistent', password: 'password' } }
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Player not found.')
      end
    end
  end

  describe 'POST #logout' do
    context 'when the player is a guest' do
      let!(:guest) { create(:guest_player) }
      let(:token) { JsonWebToken.encode(player_id: guest.id) }

      it 'destroys the guest player and returns success' do
        expect {
          post '/api/v1/players/logout', headers: { 'Authorization' => "Bearer #{token}" }
        }.to change(Player, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be_truthy
      end
    end

    context 'when the player is not a guest' do
      let!(:player) { create(:player) }
      let(:token) { JsonWebToken.encode(player_id: player.id) }

      it 'returns a logged out message without deleting the player' do
        expect {
          post '/api/v1/players/logout', headers: { 'Authorization' => "Bearer #{token}" }
        }.not_to change(Player, :count)
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Logged out.')
      end
    end
  end

  describe 'POST #covert_to_registered' do
    let(:guest_player) { create(:player, is_guest: true, username: 'GuestUser') }
    let(:registered_player) { create(:player, is_guest: false) }
  
    # Generate a valid JWT for the given player.
    def auth_header_for(player)
      token = JsonWebToken.encode(player_id: player.id)
      { 'Authorization' => "Bearer #{token}" }
    end
    
    context "when the account is already registered" do
      it "returns a forbidden status" do
        post "/api/v1/players/convert_to_registered", 
          params: { player: { username: 'NewName', password: 'newpassword' } },
          headers: auth_header_for(registered_player)
          
        expect(response).to have_http_status(:forbidden)
        expect(json_response['error']).to eq('This account is already registered.')
      end
    end

    context "when the password is too short" do
      it "returns a bad request status" do
        post "/api/v1/players/convert_to_registered", 
             params: { player: { username: 'NewName', password: '123' } },
             headers: auth_header_for(guest_player)

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Password must be at least 6 characters long.')
      end
    end

    context "when the conversion parameters are valid" do
      let(:new_username) { 'NewUser' }
      let(:new_password) { 'securepassword' }

      it "updates the player to a registered account" do
        post "/api/v1/players/convert_to_registered", 
             params: { player: { username: new_username, password: new_password } },
             headers: auth_header_for(guest_player)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true

        # Reload the player to check updates
        guest_player.reload
        expect(guest_player.username).to eq(new_username)
        expect(guest_player.is_guest).to be_falsey
      end
    end

    context "when the update fails due to invalid parameters" do
      it "returns a bad request status" do
        post "/api/v1/players/convert_to_registered", 
             params: { player: { username: '', password: 'securepassword' } },
             headers: auth_header_for(guest_player)

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end
    end
  end

  describe 'POST #update_password' do
    let(:player) { create(:player) }
    let(:token) { JsonWebToken.encode(player_id: player.id) }

    it 'updates player password successfully' do
      post '/api/v1/players/update_password',
        params: { player: { password: 'password123', new_password: 'newsecurepass' }},
        headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      
      player.reload
      expect(player.authenticate('newsecurepass')).to be_truthy
    end

    it 'returns an error if the current password is incorrect' do
      post '/api/v1/players/update_password',
        params: { player: { password: 'wrongpassword', new_password: 'newsecurepass' }},
        headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE #destroy' do
    let(:player) { create(:player) }
    let(:token) { JsonWebToken.encode(player_id: player.id) }
    
    it 'deletes the player if authenticated' do
      delete '/api/v1/players/delete',
        params: { player: { password: 'password123' }},
        headers: { 'Authorization' => "Bearer #{ token }" }

      expect(response).to have_http_status(:ok)
      expect(Player.exists?(player.id)).to be false
    end

    it 'returns an error if the password is incorrect' do
      delete '/api/v1/players/delete',
        params: { player: { password: 'wrongpassword' }},
        headers: { 'Authorization' => "Bearer #{ token }" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #show' do
    let!(:player) { create(:player) }
    let(:token) { JsonWebToken.encode(player_id: player.id) }

    it 'returns the current player details' do
      get '/api/v1/players/show', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)

      show_player = json_response['player']
      expect(show_player['username']).to eq(player.username)
      expect(show_player['blood_pool']).to eq(player.blood_pool)
      expect(show_player['is_guest']).to eq(player.is_guest)
      expect(show_player['tutorial_finished']).to eq(player.tutorial_finished)

    end
  end

  describe 'GET /api/v1/players/leaderboard/rounds' do
    before do
      create(:player, username: 'Alice', max_round_reached: 10)
      create(:player, username: 'Bob', max_round_reached: 5)
      create(:player, username: 'Charlie', max_round_reached: 20)
    end

    it 'returns players sorted by max_round_reached in descending order' do
      get '/api/v1/players/leaderboard/rounds'

      expect(response).to have_http_status(:ok)

      players = json_response["players"]

      expect(players.length).to eq(3)


      # Check the correct order (ascending)
      expect(players[0]['username']).to eq('Charlie')     # 5 rounds (lowest)
      expect(players[1]['username']).to eq('Alice')   # 10 rounds
      expect(players[2]['username']).to eq('Bob') # 20 rounds (highest)
    end
  end
end
