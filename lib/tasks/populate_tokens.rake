#heroku run rake tokens:populate_tokens
namespace :tokens do
  desc "Populate tokens"
  task populate_tokens: :environment do
    tokens = [{
      name: 'Eye of Tyche',
      rune: 'φ',
      description: 'Tyche has taken mercy, granting you the ability to see what others cannot. But will you see what really matters?',
      effect_type: 'Utility',
      lore_token: true,
      sequence_order: 0,
      inscribed_effect: 'Unveil the card count, letting you track the balance of high and low cards.',
      oathbound_effect: 'Glimpse ahead, know whether the next card will raise or lower the count.',
      offering_effect: 'See beyond fate itself. The next card in the deck is revealed to you.'
    }, {
      name: 'Red Tearstone Token',
      rune: 'Θ',
      description: 'Tyche rewards those who dare play the odds - for a great wager deserves a great reward. But be certain you can withstand the cost.',
      effect_type: 'Damage',
      lore_token: false,
      inscribed_effect: "The token's red glow slightly damages the house when the user limits their vigor.",
      oathbound_effect: "The red glow drains the house's strength but such power requirest a cost.",
      offering_effect: 'A large gamble brings great bounty. Wager half your strength but the house will follow suit.'
    }]

    tokens.each do |token_data|
      Token.find_or_create_by!(name: token_data[:name]) do |token|
        token.rune = token_data[:rune]
        token.description = token_data[:description]
        token.effect_type = token_data[:effect_type]
        token.lore_token = token_data[:lore_token]
        token.sequence_order = token_data[:sequence_order]
        token.inscribed_effect = token_data[:inscribed_effect]
        token.oathbound_effect = token_data[:oathbound_effect]
        token.offering_effect = token_data[:offering_effect]
      end
    end

    puts "Tokens populated successfully "
  end
end