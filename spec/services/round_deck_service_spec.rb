require 'rails_helper'

RSpec.describe RoundDeckService, type: :service do
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
  
  let!(:daimon) { create(:daimon, progression_level: 0) }
  let!(:player) { create(:player) }
  let!(:non_tut_player) { create(:player, tutorial_finished: true) }
  let(:game) { create(:game, player: player) }
  let(:round) { game.rounds.first }
  let(:service) { RoundDeckService.new(round) }
  let(:card1) { create(:card, rank: 'Ace') }
  let(:card2) { create(:card, rank: '10') }
  let(:card3) { create(:card, rank: 'Jack') }
  let(:card4) { create(:card, rank: 'King') }
  let(:card5) { create(:card, rank: 'Ace', effect: "Blessed")}

  describe "#shuffle_deck" do
    it "shuffles the deck and assigns it to the round with tutorial" do
      expect(player.equipped_cards.count).to eq(52)
      service.shuffle_deck
      expect(round.shuffled_deck).not_to be_empty
      expect(round.shuffled_deck.size).to eq(23) #Should match equipped_cards count
    end

    it 'shuffles the deck and assigns it to the round with tutorial finished' do
      non_tut_game = Game.create!(player: non_tut_player)
      non_tut_round = non_tut_game.rounds.first

      expect(non_tut_player.equipped_cards.count).to eq(52)
      expect(non_tut_round.shuffled_deck.count).to eq(49)
    end
  end

  describe "#reshuffle_if_empty" do
    before do
      card1 = Card.first
      card2 = Card.second
      round.update_columns(shuffled_deck: [], discard_pile: [card1.id, card2.id])
    end
    
    it 'does not reshuffle if shuffled_deck is not empty' do
      round.update_columns(shuffled_deck: [card1.id, card2.id])
      service.reshuffle_if_empty
      expect(round.shuffled_deck.count).to eq(2)
    end

    it "reshuffles discard pile into deck when deck is empty" do
      service.reshuffle_if_empty
      expect(round.shuffled_deck.count).to eq(23)
      expect(round.discard_pile).to be_empty
    end
  end
end
