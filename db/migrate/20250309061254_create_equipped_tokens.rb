class CreateEquippedTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :equipped_tokens do |t|
      t.belongs_to :token, index: true, foreign_key: { on_delete: :cascade }
      t.belongs_to :slot, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :equipped_tokens, [:token_id, :slot_id], unique: true
  end
end
