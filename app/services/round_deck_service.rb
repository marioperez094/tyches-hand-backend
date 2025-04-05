module RoundDeckService
  BIAS_CUTOFF_ROUND = 4
  BIAS_BOOST = 6.0

  #Initializes and shuffles the deck for the round
  def self.shuffle_deck(cards:, custom_weights: nil)
    #Calculate weights and shuffle deck
    weights = custom_weights || CardWeightService.calculate_card_weights(cards: cards)
    shuffled_cards = CardWeightService.randomize_cards_by_weight(cards, weights, cards.size)  
  
    shuffled_cards.map(&:id)   
  end

  def self.rank_bias_by_round(cards:, rounds:)
    return nil if rounds > BIAS_CUTOFF_ROUND || rounds == 0
    
    boost = (BIAS_BOOST / rounds)
    rank_weights = ->(card) { card.card_numeric_rank >= 10 ? boost  : 1 }

    CardWeightService.calculate_card_weights(cards: cards, rank_weights: rank_weights)
  end

  private 

  #Premade deck for the tutorial
  def self.tutorial_deck
    [279, 277, 266, 281, 282, 308, 280, 274, 284, 271, 272, 265, 286, 311, 
      278, 264, 305, 283, 285, 273, 270, 268, 292, 269, 294, 307, 293, 261, 
      262, 263, 310, 267, 275, 276, 287, 288, 289, 290, 291, 295, 296, 297, 
      298, 299, 300, 301, 302, 303, 304, 306, 309, 312
    ]
  end
end