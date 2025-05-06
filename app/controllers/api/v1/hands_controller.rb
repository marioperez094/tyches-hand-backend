class Api::V1::HandsController < ApplicationController
  before_action :set_hand, except: [:create]

  def create
    game = current_player&.game
    round = game&.round

    unless round
      return render json: { error: 'No round was found.' },
      status: :unprocessable_entity
    end

    @hands_played = round.hands_played
    hand_init = HandInitializer.new(round)
    @hand = round.hand&.in_progress? ? round.hand : hand_init.build_new_hand
    hand_service = HandService.new(@hand)

    @wagered_health_statuses = hand_service.health_compiler
    @daimon_cards = @hand.daimon_hand_cards
    player_cards = @hand.player_hand_cards
    @player_card_effects = hand_service.apply_card_effects(player_cards)

    @actions = hand_service.available_player_actions 
    @health_statuses = nil

    if Hand.is_blackjack?(player_cards)
      @daimon_cards =  hand_service.daimon_draws
      result = @hand.hand_result?
      
      @hand.hand_resolution(result)
      @health_statuses = hand_service.health_compiler
    end

    @hand.manager_persist_changes

    unless @hand.persisted?
      return render json: { error: 'Failed to create hand.' }, status: :unprocessable_entity
    end

    render 'api/hands/hand_setup'
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def player_hits
    @player_hits = @hand_service.player_draws
    @actions = @hand_service.available_player_actions

    @health_statuses = @hand.player_hand_bust? ? @hand.hand_resolution(:lost) : nil
    
    @hand.manager_persist_changes
    
    render 'api/hands/player_hits'
  end

  def player_stands
    @daimon_cards =  @hand_service.daimon_draws
    result = @hand.hand_result?
    
    @hand.hand_resolution(result)
    
    @health_statuses = @hand_service.health_compiler

    @hand.manager_persist_changes

    render 'api/hands/player_stands'
  end

  def player_surrenders
    deduct_wager = @hand.blood_wager / 4
    @hand.manager.set_player_health(deduct_wager)
    @hand.manager.set_blood_wager(-deduct_wager)

    @hand.hand_resolution(:lost)

    @health_statuses = @hand_service.health_compiler

    @hand.manager_persist_changes

    render 'api/hands/player_surrenders'
  end

  def player_doubles_down
    deduct_wager = @hand.blood_wager / 2

    @hand.manager.set_player_health(-deduct_wager)
    @hand.manager.set_daimon_health(-deduct_wager)
    @hand.manager.set_blood_wager(@hand.blood_wager)

    @wagered_health_statuses = @hand_service.health_compiler

    @player_hits = @hand_service.player_draws
    @daimon_cards = @hand_service.daimon_draws

    result = @hand.hand_result?
    @resolve_hand = @hand.hand_resolution(result)

    @health_statuses = @hand_service.health_compiler

    @hand.manager_persist_changes

    render 'api/hands/player_doubles_down'
  end

  private

  def set_hand
    game = current_player.game
    round = game&.round
    @hand = round&.hand
    
    return render json: { error: 'Hand not found.' }, 
    status: :not_found unless @hand

    @hand_service = HandService.new(@hand)
  end
end
