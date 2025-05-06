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
  
  let!(:daimon) { create(:daimon, story_sequence: 0) }
  let!(:player) { create(:player) }
  let!(:non_tut_player) { create(:player, tutorial_finished: true) }
  let(:game) { create(:game, player: player, rounds_played: 1) }
  let(:card1) { create(:card, rank: 'Ace') }
  let(:card2) { create(:card, rank: '10') }
  let(:card3) { create(:card, rank: 'Jack') }
  let(:card4) { create(:card, rank: 'King') }
  let(:card5) { create(:card, rank: 'Ace', effect: "Blessed")}

  before do
    RoundInitializer.new(game).call
  end

  describe "#shuffle_deck" do
    let!(:round) { game.round }

    it "shuffles the deck and assigns it to the round with tutorial" do
      expect(player.equipped_cards.count).to eq(52)
      expect(round.shuffled_deck).not_to be_empty
      expect(round.shuffled_deck.size).to eq(52) #Should match equipped_cards count
    end

    it 'shuffles the deck and assigns it to the round with tutorial finished' do
      non_tut_game = Game.create!(player: non_tut_player, rounds_played: 1)
      non_tut_round = RoundInitializer.new(non_tut_game).call

      expect(non_tut_player.equipped_cards.count).to eq(52)
      expect(non_tut_round.shuffled_deck.count).to eq(52)
    end

    it 'favors high cards in initial rounds' do
      non_tut_game = Game.create!(player: non_tut_player)
      RoundInitializer.new(non_tut_game).call

      trials = 100
      high_card_counts = []

      trials.times do
        non_tut_game.round.discard_pile = non_tut_game.round.shuffled_deck
        non_tut_game.round.shuffled_deck = []
        non_tut_game.round.reshuffle_if_empty
        top_10 = non_tut_game.round.shuffled_deck.first(10)
        cards = Card.where(id: top_10)
        high_cards = cards.select { |c| c.card_numeric_rank >= 10 }
        high_card_counts << high_cards.count
      end

      average_high_cards = high_card_counts.sum.to_f / trials
      puts "#{ average_high_cards }"
      expect(average_high_cards).to be > 6
    end

    it 'decrease in favor in later rounds' do
      non_tut_game = Game.create!(player: non_tut_player, rounds_played: 3)
      RoundInitializer.new(non_tut_game).call

      trials = 100
      high_card_counts = []

      trials.times do
        non_tut_game.round.shuffled_deck = []
        non_tut_game.round.reshuffle_if_empty
        top_10 = non_tut_game.round.shuffled_deck.first(10)
        cards = Card.where(id: top_10)
        high_cards = cards.select { |c| c.card_numeric_rank >= 10 }
        high_card_counts << high_cards.count
      end

      average_high_cards = high_card_counts.sum.to_f / trials
      puts "#{ average_high_cards }"
      expect(average_high_cards).to be < 5
    end

    it 'has no bias in rounds after 5' do
      non_tut_game = Game.create!(player: non_tut_player, rounds_played: 4)
      RoundInitializer.new(non_tut_game).call

      trials = 100
      high_card_counts = []

      trials.times do
        non_tut_game.round.shuffled_deck = []
        non_tut_game.round.reshuffle_if_empty
        top_10 = non_tut_game.round.shuffled_deck.first(10)
        cards = Card.where(id: top_10)
        high_cards = cards.select { |c| c.card_numeric_rank >= 10 }
        high_card_counts << high_cards.count
      end

      average_high_cards = high_card_counts.sum.to_f / trials
      puts "#{ average_high_cards }"
      expect(average_high_cards).to be < 4
    end
  end
end
