require 'rails_helper'

RSpec.describe 'Api::V1::Players', type: :request do
  describe 'GET /api/v1/players/leaderboard/rounds' do
    before do
      create(:player, username: 'Alice', max_round_reached: 10)
      create(:player, username: 'Bob', max_round_reached: 5)
      create(:player, username: 'Charlie', max_round_reached: 20)
    end

    it 'returns players sorted by max_round_reached in descending order' do
      get '/api/v1/players/leaderboard/rounds'

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      players = json["players"]

      expect(players.length).to eq(3)


      # Check the correct order (ascending)
      expect(players[0]['username']).to eq('Charlie')     # 5 rounds (lowest)
      expect(players[1]['username']).to eq('Alice')   # 10 rounds
      expect(players[2]['username']).to eq('Bob') # 20 rounds (highest)
    end
  end
end
