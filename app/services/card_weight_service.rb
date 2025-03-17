class CardWeightService
  def self.calculate_card_weights(cards:, rank_weights: ->(_) { 1 }, effect_weights: ->(_) { 1 }, suit_weights: ->(_) { 1 })
    cards.map do |card|
      rank_weight = rank_weights.call(card)
      effect_weight = effect_weights.call(card)
      suit_weight = suit_weights.call(card)

      rank_weight.to_f * effect_weight.to_f * suit_weight.to_f
    end
  end

  def self.randomize_cards_by_weight(cards, weights, count)
    cards = cards.to_a
    weights = weights.to_a
    raise ArgumentError, "Cards and weights size must match" unless cards.size == weights.size
    
    cumulative_weights = weights.dup
    cumulative_weights.each_with_index { |w, i| cumulative_weights[i] += cumulative_weights[i - 1] if i > 0 }
    total_weight = cumulative_weights.last
  
    selected_cards = []
  
    count.times do
      break if cards.empty?
  
      random = rand * total_weight
      selected_card_index = cumulative_weights.bsearch_index { |w| w > random } || 0
  
      #Add selected card
      selected_cards << cards[selected_card_index]
  
      #Swap selected card to the end and reduce selection range instead of deleting
      cards[selected_card_index], cards[-1] = cards[-1], cards[selected_card_index]
      weights[selected_card_index], weights[-1] = weights[-1], weights[selected_card_index]
  
      #Remove last element (now the selected card) efficiently
      removed_weight = weights.pop
      cards.pop
      total_weight -= removed_weight
  
      #Adjust cumulative weights dynamically (avoids full recompute)
      cumulative_weights[selected_card_index..-1].each_with_index do |_, i|
        next_index = selected_card_index + i
        break if next_index >= cumulative_weights.size
  
        cumulative_weights[next_index] -= removed_weight
      end
      cumulative_weights.pop  #Remove last cumulative sum
    end
  
    selected_cards
  end  
end
