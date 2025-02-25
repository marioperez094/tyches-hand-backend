class CreateDecks < ActiveRecord::Migration[7.2]
  def change
    create_table :decks do |t|
      t.string :name, null: false
      t.references :player, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
