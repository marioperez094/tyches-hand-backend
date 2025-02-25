class CreatePlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :players do |t|
      t.string :username, null: false
      t.string :password_digest
      t.boolean :is_guest, default: false, null: false
      t.boolean :tutorial_finished, default: false, null: false
      t.integer :blood_pool, default: 5000, null: false
      t.integer :max_daimon_health_reached, default: 0, null: false
      t.integer :max_round_reached, default: 0, null: false
      t.integer :lore_progression, default: 0, null: false

      t.timestamps
    end

    add_index :players, :username, unique: true
    add_index :players, :max_daimon_health_reached
    add_index :players, :max_round_reached
    add_index :players, [:max_daimon_health_reached, :max_round_reached], name: "index_players_on_max_daimon_health_and_round"
  end
end
