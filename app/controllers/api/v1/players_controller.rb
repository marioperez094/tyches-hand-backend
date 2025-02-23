class Api::V1::PlayersController < ApplicationController 
  def index_leaderboard_by_rounds
    @players = Player.order(max_round_reached: :desc)
    render 'api/players/index_leaderboard',
    status: :ok
  end
end
