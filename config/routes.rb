Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'players/leaderboard/rounds', to: 'players#index_leaderboard_by_rounds'
    end
  end
end
