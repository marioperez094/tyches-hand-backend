Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      #Player Routes
      resources :players, only: [:create] do
        post 'login', on: :collection, to: 'players#login'
        put 'update_password', on: :collection, to: 'players#update_password'
        put 'convert_to_registered', on: :collection, to: 'players#convert_to_registered'
        delete 'delete', on: :collection, to: 'players#destroy'
        delete 'logout', on: :collection, to: 'players#logout'
        get 'authenticated', on: :collection, to: 'players#authenticated'
        get 'show', on: :collection, to: 'players#show'
        get 'leaderboard/rounds', on: :collection, to: 'players#index_leaderboard_by_rounds'
      end
      
      #Card Routes
      resources :cards, only: [:show]

      #Deck Routes
      resources :decks do
        put 'rename', on: :collection, to: 'decks#rename_deck'
        put 'update_cards', on: :collection, to: 'decks#update_cards'
      end

      #Token Routes
      resources :tokens, only: [:show]

      #Slot Routes
      resources :slots do
        put 'update_tokens', on: :collection, to: 'slots#update_tokens'
      end

      #Game Routes
      resources :games, only: [:create] do
        get 'show_player_stats', on: :collection, to: 'games#show_player_stats'
      end
    end
  end
end
