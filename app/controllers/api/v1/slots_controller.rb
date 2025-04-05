class Api::V1::SlotsController < ApplicationController
  def update_tokens
    ActiveRecord::Base.transaction do
      #Removes equipped tokens to prevent duplicate errors
      slot_ids = params[:slots].map { |slot| slot[:id] }
      EquippedToken.where(slot_id: slot_ids).destroy_all

      params[:slots].each do |slot_params|
        #Skip empty slots - player chose not to equip a token here
        next unless slot_params[:token_id].present?
        
        slot = current_player.slots.find(slot_params[:id])
        token_collection = slot.convert_to_collection_ids(slot_params[:token_id]).first
        
        unless token_collection
          record = slot.equipped_token || slot.build_equipped_token
          record.errors.add(:token, 'is not owned by the player.')
          raise ActiveRecord::RecordInvalid.new(record)
        end
  
  
        #Only adds a token if one is present
        slot.create_equipped_token!(token_collection_id: token_collection&.id)
      end
    end

    render json: { success: true },
    status: :ok

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, 
    status: :unprocessable_entity
  end
end
