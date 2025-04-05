require 'rails_helper'

RSpec.describe "Api::V1::Decks", type: :request do
  let!(:standard_cards) do
    suits = Card::SUITS
    ranks = Card::RANKS
    suits.product(ranks).map do |suit, rank|
      create(:card,
        effect: 'Standard',
        suit: suit,
        rank: rank
      )
    end
  end

  let(:player) { create(:player) }
  let!(:deck) { player.deck }
  let(:json_response) { JSON.parse(response.body) }

  # Generate a valid JWT for the given player.
  def auth_header_for(player)
    token = JsonWebToken.encode(player_id: player.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'PUT #rename_deck' do
    it 'renames the deck successfully' do
      put '/api/v1/decks/rename', 
        params: { deck: { name: "Renamed Deck" }},
        headers: auth_header_for(player)
      
      expect(response).to have_http_status(:ok)
      deck.reload
      expect(deck.name).to eq("Renamed Deck")
    end

    it "returns an error if no player is found" do
      put '/api/v1/decks/rename', 
        params: { deck: { name: "Renamed Deck" }}

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT #update_cards" do
    let!(:exhumed_cards) do
      suits = Card::SUITS
      ranks = Card::RANKS
      suits.product(ranks).map do |suit, rank|
        create(:card,
          effect: 'Exhumed',
          suit: suit,
          rank: rank
        )
      end
    end

    it "returns an error if a player does not own some of the cards" do
      new_cards = Card.by_effect("Exhumed")
      
      put "/api/v1/decks/update_cards", 
        params: { deck: { cards: new_cards.map { |c| { id: c.id } } } }, 
        headers: auth_header_for(player)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns an error if fewer than 52 cards are provided' do
      new_cards = player.cards.take(50)
      
      put "/api/v1/decks/update_cards", 
        params: { deck: { cards: new_cards.map { |c| { id: c.id } } } }, 
        headers: auth_header_for(player)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "updates cards successfully when exactly 52 cards are provided" do
      player.cards << exhumed_cards

      expect(player.cards.count).to eq(104)
      
      put "/api/v1/decks/update_cards", 
        params: { deck: { cards: exhumed_cards.map { |c| { id: c.id } } } },
        headers: auth_header_for(player)

      expect(response).to have_http_status(:ok)
      expect(deck.cards.count).to eq(52)
    end
  end
end
