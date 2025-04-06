require 'rails_helper'

RSpec.describe "Api::V1::Hands", type: :request do
  let(:json_response) { JSON.parse(response.body) }
  let!(:standard_cards) do
    Card::EFFECTS.each do |effect|
      Card::SUITS.each do |suit|
        Card::RANKS.each do |rank|
          FactoryBot.create(:card, rank: rank, suit: suit, effect: effect)
        end
      end
    end
  end

  let!(:player) { create(:player) }
  let!(:daimon) { create(:daimon, story_sequence: 0) }
  let!(:play_token) { create(:token) }
  let(:token) { JsonWebToken.encode(player_id: player.id) }
  let!(:game) { create(:game, player: player) }

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

  before do
    collection = player.token_collections.create!(token: play_token)
    EquippedToken.create!(slot_id: player.inscribed_slot.id, token_collection_id: collection.id)
    round = RoundInitializer.new(game).call
    round.manager_persist_changes
  end

  describe 'Post #create' do
    context 'hand exists' do
      let!(:hand) { create(:hand, round: player.game.round) }

      it 'does not create a new hand if the player has a hand in progress' do
        post '/api/v1/hands', headers: { 'Authorization' => token }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('A hand is already active.')
      end

      it 'creates a new hand if the player has finished the last hand' do
        hand.update!(status: :won)
        game.round.increment!(:hands_played)

        post '/api/v1/hands', headers: { 'Authorization' => token }

        expect(game.round.reload.hand.id).to eq(2)
        expect(Hand.count).to eq(1)

        round = game&.round
        hand = round&.hand
        player_hand = hand.player_hand_cards
        first_card = player_hand.first
        second_card = player_hand.second

        expect(game.round.reload.hands_played).to eq(2)

        show_hand = json_response
        expect(show_hand['player_cards'].first['name']).to eq(first_card.name)
        expect(show_hand['player_cards'].second['name']).to eq(second_card.name)
        
        expect(show_hand['daimon_cards'].first['name']).to eq(hand.daimon_hand_cards.first.name)
        
        expect(show_hand['hand_setup'].first['source']).to eq('wager')

      end
    end

    context 'no previous hand' do
      it 'creates a new hand if the player has no previous hand' do
        expect {
          post '/api/v1/hands', headers: { 'Authorization' => token }
        }.to change(Hand, :count).by(1)

        round = game&.round
        hand = round.reload.hand
        player_hand = hand.player_hand_cards
        first_card = player_hand.first
        second_card = player_hand.second

        expect(Hand.count).to eq(1)
        expect(game.round.reload.hands_played).to eq(1)

        show_hand = json_response
        expect(show_hand['player_cards'].first['name']).to eq(first_card.name)
        expect(show_hand['player_cards'].second['name']).to eq(second_card.name)
        
        expect(show_hand['daimon_cards'].first['name']).to eq(hand.daimon_hand_cards.first.name)
        
        expect(show_hand['hand_setup'].first['source']).to eq('wager')
      end
    end
  end
end
