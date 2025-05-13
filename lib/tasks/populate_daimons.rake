#heroku run rake daimons:populate_daimons
namespace :daimons do
  desc "Populate daimons"
  task populate_daimons: :environment do
    daimons = [{
      name: 'The Draw',
      description: 'It does not ask where you come from or w',
      effect_type: 'none',
      effect_values: {},
      rune: '',
      intro: [
        "Ah...you're finally awake.", 
        "Quite brave of you to have come here.", 
        "Come sit...join me at the table.", 
        "It seems you have forgotten how to play.", 
        "No matter, all you need is something to wager with.", 
        "Mind you, money doesn't carry weight here, the stakes are a little higher."
      ],
      player_win: 'I hope this was enjoyable and you will want to keep playing.',
      dialogue: {
        "hand_count": {
          "0": [
            "Oh spare me...that drop was merely pocket change. Your crimson account still overflows.",
            "This game will be delightfully simple for a mind as keen as yours.",
            "Edge as close to twenty-one as luck permits, surpass it and the hand is yours no more.",
            "Your total of twelve against my seven...the goddess of Fortune beckons you to draw."
          ],
          "1": [
            "Astute and favored by fortune!",
            "Restraint can be the boldest move.",
            "Your eighteen teeters on the brink; one more card could betray you.",
            "Stand your ground, and your eighteen may yet conquer my hand."
          ],
          "2": [
            "Swift on the draw, but not every gamble ends in victory.",
            "Sixteen flirts with excess...while my Ace could shatter your bet.",
            "Surrender and you may regain at least some of your strength."
          ], 
          "3": [
            "Eleven against my seven...fortune truly smiles upon you.",
            "Double your wager, and draw but one card...",
            "Your bravery may greatly reward you."
          ],
          "4": [
            "Quite the fortunate twist...a blackjack.", 
            "I have no choice but to concede."
          ],
          "5": [
            "The goddess of Fortune has grown weery...",
            "She hungers for more.",
            "For now, you skirt her wrath—but Fortune’s patience is not eternal."
          ]
        },
        "player_win": [
          "The goddess of fortune has blessed you, but will luck always be in your favor?"
        ]
      },
      story_sequence: 0
    }]

    daimons.each do |daimon_data|
      Daimon.find_or_create_by!(name: daimon_data[:name]) do |daimon|
        daimon.description = daimon_data[:description]
        daimon.effect_type = daimon_data[:effect_type]
        daimon.effect_values = daimon_data[:effect_values]
        daimon.rune = daimon_data[:rune]
        daimon.intro = daimon_data[:intro]
        daimon.player_win = daimon_data[:player_win]
        daimon.dialogue = daimon_data[:dialogue]
        daimon.story_sequence = daimon_data[:story_sequence]
      end
    end

    puts 'Daimons populated successfully!'
  end
end