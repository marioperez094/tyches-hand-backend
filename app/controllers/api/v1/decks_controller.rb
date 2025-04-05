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
    #Converts card ids to player collection ids
    new_card_ids = params[:deck][:cards].map { |card| card[:id].to_i }
    new_collection_ids = @deck.convert_to_collection_ids(new_card_ids)

    return render json: { error: 'A deck must contain exactly 52 cards.'},
    status: :unprocessable_entity if new_collection_ids.size != 52

    current_collection_ids = @deck.card_collections

    #Determine which cards to add or remove
    collection_ids_to_add = new_collection_ids - current_collection_ids
    collection_ids_to_remove = current_collection_ids - new_collection_ids

    collections_to_insert = collection_ids_to_add.map do |collection|
      { deck_id: @deck.id, card_collection_id: collection.id }
    end

    #Adds new cards
    EquippedCard.insert_all(collections_to_insert) unless collections_to_insert.empty?

    #Deletes cards removed from deck
    @deck.equipped_cards.where(card_collection: collection_ids_to_remove).delete_all

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