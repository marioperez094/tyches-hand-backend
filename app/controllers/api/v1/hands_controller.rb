class Api::V1::HandsController < ApplicationController
  before_action :set_hand, except: [:create]

  def create
    if current_player.game&.round&.hand&.in_progress?
      return render json: { error: 'A hand is already active.' }, 
      status: :unprocessable_entity
    end

    round = current_player.game&.round
    hand_init = HandInitializer.new(round)

    @hand = hand_init.build_new_hand
    @hand_setup = hand_init.new_hand_compiler(@hand)
    @daimon_cards = @hand.daimon_hand_cards
    
    player_cards = @hand.player_hand_cards
    @player_card_effect = hand_init.apply_card_effects(@hand)

    if Hand.is_blackjack?(player_cards)
      
    end

    @hand.manager_persist_changes

    unless @hand.persisted?
      return render json: { error: 'Failed to create hand.' }, status: :unprocessable_entity
    end
    
    round.increment!(:hands_played)

    render 'api/hands/hand_setup'
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def player_draws
    hand_action = HandActionService.new(@hand)

    @player_draws = hand_action.player_draws

    render json: { player_draws: @player_draws }
  end

  private

  def set_hand
    game = current_player.game
    round = game&.round
    @hand = round&.hand

    unless @hand
      render json: { error: 'Hand not found.' }, status: :not_found
    end
  end
end
