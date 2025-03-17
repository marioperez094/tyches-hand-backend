class RoundDeckService
  attr_reader :round

  def initialize(round)
    @round = round
  end

  #Initializes and shuffles the deck for the round
  def shuffle_deck
    player = round.game.player
    deck_cards = player.equipped_cards
    round.discard_pile = []
    
    if !player.tutorial_finished
      return round.shuffled_deck = tutorial_deck
    end

    #Calculate weights and shuffle deck
    weights = CardWeightService.calculate_card_weights(cards: deck_cards)
    shuffled_cards = CardWeightService.randomize_cards_by_weight(deck_cards, weights, deck_cards.size)

    round.shuffled_deck = shuffled_cards.map(&:id)    
  end

  #Premade deck for the tutorial
  def tutorial_deck
    [279, 277, 266, 281, 282, 308, 280, 274, 284, 271, 278, 264, 305, 283, 285, 272, 310, 286, 311, 273, 270, 268, 292]
  end

  #Reshuffles discard pile into deck when empty
  def reshuffle_if_empty
    if round.shuffled_deck.empty?
      shuffle_deck
    end
  end
end