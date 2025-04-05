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
      intro: 'I see we have a new player.',
      player_win: 'I hope this was enjoyable and you will want to keep playing.',
      player_lose: 'N/A',
      dialogue: ['Keep playing.', 'Do not give up now'],
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
        daimon.player_lose = daimon_data[:player_lose]
        daimon.dialogue = daimon_data[:dialogue]
        daimon.story_sequence = daimon_data[:story_sequence]
      end
    end

    puts 'Daimons populated successfully!'
  end
end