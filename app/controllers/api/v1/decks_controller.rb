class Api::V1::DecksController < ApplicationController
  before_action :set_deck
  
  def rename_deck
    begin
      @deck.update!(name: params[:deck][:name])

      render json: { success: true },
      status: :ok
    rescue ArgumentError => e
      render json: { error: e.message },
      status: :bad_request
    end
  end

  def update_cards
    new_card_ids = params[:deck][:cards].map { |card| card[:id].to_i }
  
    if new_card_ids.size != 52
      return render json: { error: "A deck must contain exactly 52 cards." }, status: :unprocessable_entity
    end
  
    current_card_ids = @deck.cards.pluck(:id)
  
    # Determine which cards to add or remove
    card_ids_to_add = new_card_ids - current_card_ids
    card_ids_to_remove = current_card_ids - new_card_ids
  
    # Find invalid card selections (cards the player does not own)
    invalid_card_ids = card_ids_to_add.reject { |card_id| current_player.owns_card?(card_id) }
  
    return render json: { error: "Player does not own the following cards: #{invalid_card_ids.join(', ')}" },
    status: :unprocessable_entity if invalid_card_ids.any?
  
    cards_to_insert = card_ids_to_add.map do |card_id|
      { deck_id: @deck.id, card_id: card_id, created_at: Time.current, updated_at: Time.current }
    end
  
    EquippedCard.insert_all(cards_to_insert) unless cards_to_insert.empty?
  
    @deck.equipped_cards.where(card_id: card_ids_to_remove).delete_all
  
    if @deck.save
      render json: { success: true }, status: :ok
    else
      render json: { errors: @deck.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_deck
    @deck = current_player.deck
    return render json: { error: 'Deck not found.' },
    status: :not_found unless @deck
  end
end