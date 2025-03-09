require 'rails_helper'

RSpec.describe "Api::V1::Slots", type: :request do
  let(:json_response) { JSON.parse(response.body) }  
  let(:player) { create(:player) }
  let(:token1) { FactoryBot.create(:token) }
  let(:token2) { FactoryBot.create(:token, name: 'Ear of Tyche', rune: 'I') }
  let(:token3) { FactoryBot.create(:token, name: 'Heart of Tyche', rune: 'H')}

  let!(:inscribed_slot) { player.slots.find_by(slot_type: "Inscribed") }
  let!(:oathbound_slot_slot) { player.slots.find_by(slot_type: "Oathbound") }
  let!(:offering_slot) { player.slots.find_by(slot_type: "Offering") }

  def auth_header_for(player)
    token = JsonWebToken.encode(player_id: player.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'PUT /api/v1/slots/update_tokens' do
    it 'updates all 6 token slots successfully' do
      player.tokens << [token1, token2, token3]

      update_params = {
        slots: [
          { id: 1, token_id: token1.id },
          { id: 2, token_id: token2.id },
          { id: 3, token_id: nil },
          { id: 4, token_id: nil },
          { id: 5, token_id: token3.id },
          { id: 6, token_id: nil }
        ]
      }

      put '/api/v1/slots/update_tokens', 
        headers: auth_header_for(player),
        params: update_params

      expect(response).to have_http_status(:ok)
      expect(player.slots.first.token.id).to eq(1)
      expect(player.slots.second.token.id).to eq(2)
      expect(player.slots.third.token).to be_nil
      expect(player.slots.fourth.token).to be_nil
      expect(player.slots.fifth.token.id).to eq(3)
      expect(player.slots[5].token).to be_nil
    end

    it 'prevents assigning the same token to multiple slots' do
      player.tokens << [token1, token2, token3]

      update_params = {
        slots: [
          { id: 1, token_id: token1.id },
          { id: 2, token_id: token1.id },
          { id: 3, token_id: nil },
          { id: 4, token_id: nil },
          { id: 5, token_id: nil },
          { id: 6, token_id: nil }
        ]
      }

      put '/api/v1/slots/update_tokens', 
        headers: auth_header_for(player),
        params: update_params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to include("Token is already assigned to another slot.")
    end

    it 'allows unequipping a token' do
      inscribed_slot.create_equipped_token!(token: token1)

      expect(inscribed_slot.token.id).to eq (token1.id)

      update_params = {
        slots: [{ id: inscribed_slot.id, token_id: nil }]
      }

      put '/api/v1/slots/update_tokens', 
        headers: auth_header_for(player),
        params: update_params

      expect(response).to have_http_status(:ok)
      expect(player.slots.first.equipped_token).to be_nil
    end

    it 'returns an error when assigning a token the player does not own' do
      other_token = create(:token, name: 'Toe of Tyche', rune: 'T')

      update_params = {
        slots: [{ id: inscribed_slot.id, token_id: other_token.id }]
      }

      put '/api/v1/slots/update_tokens', 
        headers: auth_header_for(player),
        params: update_params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to include("Player does not own this token.")
    end
  end
end
