#heroku run rake daimons:populate_daimons
namespace :daimons do
  desc "Populate daimons"
  task populate_daimons: :environment do
    daimons = [{
      name: 'The Draw',
      effect: 'none',
      effect_type: 'None',
      rune: 'O', 
      intro: 'I see we have a new player.',
      player_win: 'I hope this was enjoyable and you will want to keep playing.',
      player_lose: 'N/A',
      taunts: ['Keep playing.', 'Do not give up now'],
      progression_level: 0
    }]

    daimons.each do |daimon_data|
      Daimon.find_or_create_by!(name: daimon_data[:name]) do |daimon|
        daimon.effect = daimon_data[:effect]
        daimon.effect_type = daimon_data[:effect_type]
        daimon.rune = daimon_data[:rune]
        daimon.intro = daimon_data[:intro]
        daimon.player_win = daimon_data[:player_win]
        daimon.player_lose = daimon_data[:player_lose]
        daimon.taunts = daimon_data[:taunts]
        daimon.progression_level = daimon_data[:progression_level]
      end
    end

    puts 'Daimons populated successfully'
  end
end