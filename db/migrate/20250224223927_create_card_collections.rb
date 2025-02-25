class CreateCardCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :card_collections do |t|
      t.belongs_to :player, index: true, foreign_key: { on_delete: :cascade }
      t.belongs_to :card, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :card_collections, [:player_id, :card_id], unique: true
  end
end
