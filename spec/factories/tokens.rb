FactoryBot.define do
  factory :token do
    name { 'Eye of Tyche' }
    rune { 'Ω' }
    description { 'Tyche takes mercy to give you the upper hand. Gain the ability to see what others cannot.' }
    effect_type { 'Utility' }
    inscribed_effect { 'Gain the ability to see the current card count to better suit your odds.' }
    oathbound_effect { 'Know whether the next card count will increase or decrease the card count.' }
    offering_effect { 'See the future by showing what card will be next in the deck.' }
    lore_token { false }
    sequence_order { nil }
  end
end
