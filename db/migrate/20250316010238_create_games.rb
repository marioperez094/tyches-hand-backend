class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.references :player, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.integer :story_daimon_progress, default: -1, null: false                #Tracks the last daimon faced by the player
      t.integer :current_round, default: 1, null: false                         #Tracks the current round
      t.integer :status, default: 0, null: false                                #Enum: 0 = in_progress, 1 = lost
      

      #Player-specific stats
      t.integer :total_hands_won, default: 0, null: false
      t.integer :total_hands_lost, default: 0, null: false
      t.integer :win_streak, default: 0, null: false
      t.integer :longest_win_streak, default: 0, null: false

      t.timestamps
    end
  end
end
