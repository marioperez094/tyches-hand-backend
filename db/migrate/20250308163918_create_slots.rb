class CreateSlots < ActiveRecord::Migration[7.2]
  def change
    create_table :slots do |t|
      t.string :slot_type, null: false  # Inscribed, Oathbound, or Offering
      t.references :player, null: false, index: true, foreign_key: { on_delete: :cascade }
      
      t.timestamps
    end
  end
end
