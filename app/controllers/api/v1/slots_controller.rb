class Api::V1::SlotsController < ApplicationController
  def update_tokens
    ActiveRecord::Base.transaction do
      #Removes equipped tokens to prevent duplicate errors
      slot_ids = params[:slots].map { |slot| slot[:id] }
      EquippedToken.where(slot_id: slot_ids).destroy_all

      params[:slots].each do |slot_params|
        #Confirms player owns the slot and the player owns the token
        slot = current_player.slots.find(slot_params[:id])
        token = current_player.tokens.find_by(id: slot_params[:token_id]) if slot_params[:token_id].present?

        #If the player does not own the token or the token doesn't exist, it returns an error
        if slot_params[:token_id].present? && token.nil?
          return render json: { error: 'Player does not own this token.' }, 
          status: :unprocessable_entity
        end

        #Only adds a token if there's a token present, can unequip a slot and no error will return
        slot.create_equipped_token!(token_id: token.id) if token.present?
      end
    end

    render json: { success: true },
    status: :ok

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, 
    status: :unprocessable_entity
  end
end
