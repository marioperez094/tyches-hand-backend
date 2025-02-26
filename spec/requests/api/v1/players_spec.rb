require 'rails_helper'

RSpec.describe 'Api::V1::Players', type: :request do
  let(:json_response) { JSON.parse(response.body) }
  
  let!(:player) { create(:player) }
  let!(:guest) { create(:guest_player) }
  let(:valid_attributes) { { username: 'testuser', password: 'password', password_confirmation: 'password' } }
  let(:invalid_attributes) { { username: '', password: 'password', password_confirmation: 'password' } }
  
  # Generate a valid JWT for the given player.
  def auth_header_for(player)
    token = JsonWebToken.encode(player_id: player.id)
    { 'Authorization' => "Bearer #{token}" }
  end


  describe 'POST #create' do
    context 'with valid parameters' do
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
      it 'destroys the guest player and returns success' do
        expect {
          post '/api/v1/players/logout', headers: auth_header_for(guest)
        }.to change(Player, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be_truthy
      end
    end

    context 'when the player is not a guest' do
      it 'returns a logged out message without deleting the player' do
        expect {
          post '/api/v1/players/logout', headers: auth_header_for(player)
        }.not_to change(Player, :count)
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Logged out.')
      end
    end
  end

  context 'when there is no account' do
    it 'returns an unauthorized status' do
      post '/api/v1/players/convert_to_registered',
        params: { player: { username: 'NewName', password: 'newpassword' }}
  
      expect(response).to have_http_status(:unauthorized) # FIX: should be unauthorized
      expect(json_response).to eq({ 'error' => 'Unauthorized' }) # Match error message
    end
  end

  describe 'POST #covert_to_registered' do
    context 'when the account is already registered' do
      it 'returns a forbidden status' do
        post '/api/v1/players/convert_to_registered', 
          params: { player: { username: 'NewName', password: 'newpassword' } },
          headers: auth_header_for(player)
          
        expect(response).to have_http_status(:forbidden)
        expect(json_response['error']).to eq('This account is already registered.')
      end
    end

    context 'when the password is too short' do
      it 'returns a bad request status' do
        post '/api/v1/players/convert_to_registered', 
             params: { player: { username: 'NewName', password: '123' } },
             headers: auth_header_for(guest)

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Password must be at least 6 characters long.')
      end
    end

    context 'when the conversion parameters are valid' do
      it 'updates the player to a registered account' do
        post '/api/v1/players/convert_to_registered', 
             params: { player: { username: 'Newuser', password: 'securepassword' } },
             headers: auth_header_for(guest)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true

        # Reload the player to check updates
        guest.reload
        expect(guest.username).to eq('Newuser')
        expect(guest.is_guest).to be_falsey
      end
    end

    context 'when the update fails due to invalid parameters' do
      it 'returns a bad request status' do
        post '/api/v1/players/convert_to_registered', 
             params: { player: { username: '', password: 'securepassword' } },
             headers: auth_header_for(guest)

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end
    end
  end

  describe 'POST #update_password' do
    it 'updates player password successfully' do
      post '/api/v1/players/update_password',
        params: { player: { password: 'password123', new_password: 'newsecurepass' }},
        headers: auth_header_for(player)
      expect(response).to have_http_status(:ok)
      
      player.reload
      expect(player.authenticate('newsecurepass')).to be_truthy
    end

    it 'returns an error if the current password is incorrect' do
      post '/api/v1/players/update_password',
        params: { player: { password: 'wrongpassword', new_password: 'newsecurepass' }},
        headers: auth_header_for(player)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE #destroy' do    
    it 'deletes the player if authenticated' do
      delete '/api/v1/players/delete',
        params: { player: { password: 'password123' }},
        headers: auth_header_for(player)

      expect(response).to have_http_status(:ok)
      expect(Player.exists?(player.id)).to be false
    end

    it 'returns an error if the password is incorrect' do
      delete '/api/v1/players/delete',
        params: { player: { password: 'wrongpassword' }},
        headers: auth_header_for(player)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #authenticated' do
    context 'when player is authenticated' do
      it 'returns authenticated: true' do
        get '/api/v1/players/authenticated', headers: auth_header_for(player)

        expect(response).to have_http_status(:ok)
        expect(json_response['authenticated']).to eq(true)
      end
    end

    context 'when player is not authenticated' do
      it 'returns authenticated: false' do
        get '/api/v1/players/authenticated'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end

    context 'when token is invalid' do
      it 'returns authenticated: false' do
        get '/api/v1/players/authenticated', headers: { 'Authorization' => 'Bearer invalidtoken' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Player not found.')
      end
    end
  end

  describe 'GET #show' do
    it 'returns the current player details' do
      get '/api/v1/players/show', headers: auth_header_for(player)
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
      get '/api/v1/players/leaderboard/rounds', headers: auth_header_for(player)


      expect(response).to have_http_status(:ok)

      players = json_response['players']

      expect(players.length).to eq(5)


      # Check the correct order (ascending)
      expect(players[0]['username']).to eq('Charlie')     # 5 rounds (lowest)
      expect(players[1]['username']).to eq('Alice')   # 10 rounds
      expect(players[2]['username']).to eq('Bob') # 20 rounds (highest)
      expect(players[3]['username']).to include('Guest')
      expect(players[4]['username']).to include('TestPlayer')
    end
  end
end
