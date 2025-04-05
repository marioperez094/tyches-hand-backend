class CreateTokenCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :token_collections do |t|
      t.belongs_to :player, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :token, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :token_collections, [:player_id, :token_id], unique: true
  end
end
