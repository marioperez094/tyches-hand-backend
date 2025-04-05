require 'rails_helper'

RSpec.describe Hand, type: :model do
  let!(:standard_cards) do
    Card::EFFECTS.each do |effect|
      Card::SUITS.each do |suit|
        Card::RANKS.each do |rank|
          FactoryBot.create(:card, rank: rank, suit: suit, effect: effect)
        end
      end
    end
  end

  describe 'Validations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player) }
    let!(:round) { game.round }

    context 'basic attributes' do
      it 'is valid with all attributes' do
        hand = build(:hand, round: round)
        expect(hand).to be_valid
      end

      it 'is invalid without a blood wager' do
        hand = build(:hand, round: round, blood_wager: nil)
        expect(hand).not_to be_valid
      end

      it 'requires blood wager to be a number' do
        hand = build(:hand, round: round, blood_wager: 's')
        expect(hand).not_to be_valid
      end

      it 'requires blood wager to not be negative' do
        hand = build(:hand, round: round, blood_wager: -1)
        expect(hand).not_to be_valid
      end

      it 'is invalid without a status' do
        hand = build(:hand, round: round, status: nil)
        expect(hand).not_to be_valid
      end

      it 'is invalid with an incorrect status' do
        hand = create(:hand, round: round)
        expect { hand.status = :win }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Associations' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player) }
    let!(:round) { game.round }
    let!(:hand) { create(:hand, round: round) }

    it 'belongs to a round' do
      expect(hand.round).to eq(round)
    end
  end

  describe 'Instance Methods' do
    let!(:player) { create(:player) }
    let!(:daimon) { create(:daimon) }
    let!(:game) { create(:game, player: player) }
    let!(:round) { game.round }
    let!(:hand) { round.create_new_hand }

    context '#draw_player_card' do
      it 'draws a new card from the deck' do
        expect(hand.player_hand.count).to eq(2)

        new_card = hand.draw_player_card

        expect(new_card.first[:card]).to eq(Card.find(281))

        expect(hand.player_hand.count).to eq(3)
        expect(hand.player_hand.third).to eq(281)
      end

      context 'player tutorial_finished = true' do
        let!(:new_player) { create(:player, username: 'new_test', tutorial_finished: true)}
        let!(:new_game) { create(:game, player: new_player) }
        let!(:new_round) { new_game.round }
        let!(:new_hand) { new_round.create_new_hand }
        it 'reshuffles an empty deck on future draws' do
          expect(new_round.shuffled_deck.count).to eq(49)

          new_round.discard_pile = new_round.shuffled_deck
          new_round.shuffled_deck = []

          expect(new_round.shuffled_deck).to be_empty
         
          expect(new_hand.player_hand.count).to eq(2)
          expect(new_hand.daimon_hand.count).to eq(1)

          new_card = new_hand.draw_player_card

          expect(new_player.equipped_cards).to include(new_card.first[:card])
          expect(new_round.shuffled_deck.count).to eq(48)
        end
      end
    end

    context '#hand_total' do
      it 'gives the total of the given hand' do
        hand = [1, 2, 3]
        cards = Hand.full_cards(hand)
        expect(Hand.hand_total(cards)).to eq(9)
      end

      it 'converts face cards to numbered ranks' do
        hand = [10, 11, 12]
        cards = Hand.full_cards(hand)
        expect(Hand.hand_total(cards)).to eq(30)
      end

      it 'converts aces to 11' do
        hand = [12, 13]
        cards = Hand.full_cards(hand)
        expect(Hand.hand_total(cards)).to eq(21)
      end

      it 'converts aces to 1 if over 21' do
        hand = [11, 12, 13]
        cards = Hand.full_cards(hand)
        expect(Hand.hand_total(cards)).to eq(21)
      end

      it 'converts one ace to 11 and one ace to 1' do
        hand = [8, 13, 26]
        cards = Hand.full_cards(hand)
        expect(Hand.hand_total(cards)).to eq(21)
      end
    end

    context '#player_stand' do
      it 'draws cards until total is at least 17' do
        low_card_ids = [1, 4, 9, 10, 2, 3]
        round.update!(shuffled_deck: low_card_ids)
        hand.update!(daimon_hand: []) 


        result = hand.player_stand
        total = Hand.hand_total(hand.reload.daimon_hand)
    
        expect(total).to be >= 17
        expect(total).to eq(17)
        expect(result).to all(be_a(Card))
      end
    end

    context '#player_hand_bust?' do
      it 'returns false if the player hand is less than 21' do
        player_hand = [1, 2]
        hand.update!(player_hand: player_hand)

        expect(hand.player_hand_bust?).to eq(false)
      end

      it 'returns false if the player hand is equal to 21' do
        player_hand = [10, 13]
        hand.update!(player_hand: player_hand)

        expect(hand.player_hand_bust?).to eq(false)
      end

      it 'returns true if the player hand is greater than 21' do
        player_hand = [9, 10, 11]
        hand.update!(player_hand: player_hand)

        expect(hand.player_hand_bust?).to eq(true)
      end
    end
  end
end