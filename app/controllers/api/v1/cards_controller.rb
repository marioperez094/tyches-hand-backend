class Api::V1::CardsController < ApplicationController
  before_action :set_card

  def show
    unless @current_player.owns_card?(@card.id)
      return render json: { error: 'Player does not have this card.' },
      status: :unauthorized
    end

    render 'api/cards/show',
    status: :ok
  end

  private

  def set_card
    @card = Card.find_by(id: params[:id])
    return render json: { error: 'Card not found.' },
    status: :not_found unless @card
  end
end
