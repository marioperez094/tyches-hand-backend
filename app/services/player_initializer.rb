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

    standard_cards.each do |card|
      collection = @player.card_collections.create!(card: card)
      deck.equipped_cards.create!(card_collection: collection)
    end
  end

  def initialize_slots
    {
      "Inscribed" => 1,
      "Oathbound" => 2,
      "Offering"  => 3
    }.each do |type, count|
      count.times { @player.slots.create!(slot_type: type) }
    end
  end
end