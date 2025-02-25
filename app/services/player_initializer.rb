#Initialize all player associations
Class PlayerInitializer
  def initialize(player)
    @player = player
  end

  def call
    ActiveRecord::Base.transaction do
      initialize_deck
    end
  end

  private

  def initialize_deck
    return if @player.deck.present?

    deck = @player.create_deck!

    #Populates the deck with 52 standard cards
    standard_cards = Card.by_effect('Standard')
    
    deck.cards << standard_cards
    @player.cards << standard_cards
  end
end