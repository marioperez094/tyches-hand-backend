class Api::V1::TokensController < ApplicationController
  before_action :set_token

  def show
    #Prevents player from seeing undiscovered tokens
    unless current_player.owns_token?(@token.id)
      return render json: { error: 'Player does not have this token.' },
      status: :unauthorized
    end

    render 'api/tokens/show',
    status: :ok
  end

  private

  def set_token
    @token = Token.find_by(id: params[:id])
    return render json: { error: 'Token not found.' },
    status: :not_found unless @token
  end
end
