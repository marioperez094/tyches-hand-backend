class Api::V1::GamesController < ApplicationController
  before_action :set_game, except: [:create]

  def create
    @game = current_player.game&.in_progress? ? current_player.game : current_player.create_game!
    round = RoundInitializer.new(@game).call

    render 'api/rounds/round_setup'
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  #def show_player_stats
    #render 'api/games/stats',
    #status: :ok 
  #end

  private

  def set_game
    @game = current_player.game
    return render json: { error: 'Game not found.' },
    status: :not_found unless @game
  end
end
