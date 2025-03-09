#Initialize all player associations
class PlayerInitializer
  def initialize(player)
    @player = player
  end

  def call
    ActiveRecord::Base.transaction do
      initialize_deck
      initialize_slots
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

  def initialize_slots
    @player.slots.create!(slot_type: "Inscribed")
    2.times { @player.slots.create!(slot_type: "Oathbound") }
    3.times { @player.slots.create!(slot_type:"Offering") }
  end
end