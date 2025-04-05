require 'rails_helper'

RSpec.describe "Api::V1::Tokens", type: :request do
  let(:json_response) { JSON.parse(response.body) }  
  let!(:token) { create(:token) }
  let!(:player) { create(:player) }

  def auth_header_for(player)
    token = JsonWebToken.encode(player_id: player.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET #show' do
    context 'when the token exists and the player owns it' do
      before do
        player.tokens << token #Player owns this token
        get "/api/v1/tokens/#{ token.id }",
          headers: auth_header_for(player)
      end

      it 'returns a 200 ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the token data' do
        json_token = json_response['token']

        expect(json_token['name']).to include(token.name)
        expect(json_token['rune']).to include(token.rune)
        expect(json_token['description']).to include(token.description)
      end
    end

    context 'when the token does not exist' do
      before do
        get '/api/v1/tokens/99999', #Non-existent token ID
          headers: auth_header_for(player)
      end  

      it 'returns a 404 Not Found Status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do 
        expect(json_response['error']).to include ('Token not found.')
      end
    end

    context 'when the player does not own the card' do
      before do
        get "/api/v1/tokens/#{ token.id }", #Player does not own this token
          headers: auth_header_for(player)
      end

      it 'returns a 401 Unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        expect(json_response['error']).to include('Player does not have this token.')
      end
    end
  end
end
