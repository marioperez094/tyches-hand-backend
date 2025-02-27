#heroku run rake cards:populate_cards
namespace :cards do
  desc "Populate cards"
  task populate_cards: :environment do
    Card::EFFECTS.each do |effect|
      Card::SUITS.each do |suit|
        Card::RANKS.each do |rank|
          Card.find_or_create_by!(
            suit: suit,
            rank: rank.to_s,
            effect: effect,
          )
        end
      end
    end

    puts "Cards populated successfully!"
  end
end