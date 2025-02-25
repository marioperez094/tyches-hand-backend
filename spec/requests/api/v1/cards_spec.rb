require 'rails_helper'

RSpec.describe "Api::V1::Cards", type: :request do
  let(:json_response) { JSON.parse(response.body) }

  describe "GET #show" do
    let!(:card) { create(:card) }
    let!(:player) { create(:player) }
    let(:token) { JsonWebToken.encode(player_id: player.id) }
    
    context "when the card exists and the player owns it" do
      before do
        player.cards << card # Player owns this card
        get "/api/v1/cards/#{card.id}", headers: { 'Authorization' => token }
      end

      it "returns a 200 OK status" do
        expect(response).to have_http_status(:ok)
      end


      it "returns the card data" do
        json_card = json_response['card']

        expect(json_card['name']).to include(card.name)
        expect(json_card['suit']).to include(card.suit)
        expect(json_card['rank']).to include(card.rank)
        expect(json_card['description']).to include(card.description)
        expect(json_card['effect']).to include(card.effect)
        expect(json_card['effect_description']).to include(card.effect_description)
        expect(json_card['effect_value']).to eq(card.calculate_effect_value)
      end
    end

    context "when the card does not exist" do
      before { get "/api/v1/cards/99999", headers: { 'Authorization' => token } } # Non-existent card ID

      it "returns a 404 Not Found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response['error']).to include("Card not found.")
      end
    end

    context "when the player does not own the card" do
      before { get "/api/v1/cards/#{card.id}", headers: { 'Authorization' => token } } # Player does not own this card

      it "returns a 401 Unauthorized status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        expect(json_response['error']).to include("Player does not have this card.")
      end
    end
  end
end
