class CreateHands < ActiveRecord::Migration[7.2]
  def change
    create_table :hands do |t|
      t.references :round, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.integer :hand_number, null: false, default: 1          #Tracks hand number within the round
      t.integer :blood_wager, null: false, default: 1000

      #Hands
      t.json :player_hand, default: []
      t.json :daimon_hand, default: []

      t.integer :winner, default: 0, null: false               #Enum: 0 = in_progress, 1 = player_win, 2 = daimon_win, 3 = push

      t.timestamps
    end
  end
end
