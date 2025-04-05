class CreateEquippedCards < ActiveRecord::Migration[7.2]
  def change
    create_table :equipped_cards do |t|
      t.references :deck, null: false, foreign_key: { on_delete: :cascade }
      t.references :card_collection, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :equipped_cards, [:card_collection_id, :deck_id], unique: true
  end
end
