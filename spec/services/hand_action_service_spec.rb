require 'rails_helper'

RSpec.describe HandActionService do
  let!(:standard_cards) do
    Card::EFFECTS.each do |effect|
      Card::SUITS.each do |suit|
        Card::RANKS.each do |rank|
          FactoryBot.create(:card, rank: rank, suit: suit, effect: effect)
        end
      end
    end
  end

  let!(:player) { create(:player, blood_pool: 5000) }
  let!(:token) { create(:token) }
  let!(:daimon) { create(:daimon) }
  let!(:game) { create(:game, player: player) }
  let!(:round) { game.round }
  let!(:hand) { round.create_new_hand }

  subject(:initializer) { described_class.new(hand) }

  describe '#player_draws' do
    context 'when round has cards' do
      it "draws a card for the player's hand" do
        expect(hand.player_hand.count).to eq(2)
        draw_card = initializer.player_draws

        expect(hand.player_hand.count).to eq(3)
      end
    end
  end
end