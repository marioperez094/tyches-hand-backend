class CreateEquippedTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :equipped_tokens do |t|
      t.references :token_collection, null: false, foreign_key: { on_delete: :cascade }
      t.references :slot, null: false, foreign_key: { on_delete: :cascade }
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :equipped_tokens, [:token_collection_id, :slot_id], unique: true
  end
end
