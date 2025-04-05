class CreateRounds < ActiveRecord::Migration[7.2]
  def change
    create_table :rounds do |t|
      t.references :game, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.references :daimon, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.integer :hands_played, null: false, default: 0      #Tracks number of hands in the round

      #Deck
      t.integer :card_count, null: false, default: 0
      t.json :shuffled_deck, default: []                    #Stores shuffled deck as card IDs
      t.json :discard_pile, default: []                     #Stores discarded cards

      #Blood pools
      t.integer :player_max_blood_pool, default: 5000, null: false 
      t.integer :daimon_max_blood_pool, null: false
      t.integer :daimon_blood_pool, null: false

      t.integer :status, null: false, default: 0            #Enum: 0 = in_progress, 1 = player_win, 2 = daimon_win
      t.timestamps
    end
  end
end
