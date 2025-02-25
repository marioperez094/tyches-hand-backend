class CreateEquippedCards < ActiveRecord::Migration[7.2]
  def change
    create_table :equipped_cards do |t|
      t.belongs_to :card, index: true, foreign_key: { on_delete: :cascade }
      t.belongs_to :deck, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :equipped_cards, [:card_id, :deck_id], unique: true
  end
end
