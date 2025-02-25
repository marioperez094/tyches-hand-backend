Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      #Player Routes
      resources :players, only: [:create] do
        post 'login', on: :collection, to: 'players#login'
        post 'logout', on: :collection, to: 'players#logout'
        post 'convert_to_registered', on: :collection, to: 'players#convert_to_registered'
        post 'update_password', on: :collection, to: 'players#update_password'
        delete 'delete', on: :collection, to: 'players#destroy'
        get 'show', on: :collection, to: 'players#show'
        get 'leaderboard/rounds', on: :collection, to: 'players#index_leaderboard_by_rounds'
      end
      
      #Card Routes
      resources :cards, only: [:show]
    end
  end
end
