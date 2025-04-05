class CreateHands < ActiveRecord::Migration[7.2]
  def change
    create_table :hands do |t|
      t.references :round, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.integer :blood_wager, null: false, default: 1000      #The total wager amount given by the player and daimon

      #Hands
      t.column :player_hand, :jsonb, default: []
      t.column :daimon_hand, :jsonb, default: []

      t.integer :status, default: 0, null: false               #Enum: 0 = in_progress, 1 = player_win, 2 = daimon_win, 3 = push

      t.timestamps
    end
  end
end
