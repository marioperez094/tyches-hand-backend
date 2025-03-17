class CreateDaimons < ActiveRecord::Migration[7.2]
  def change
    create_table :daimons do |t|
      t.string :name, null: false                               #Name of the daimon
      t.string :rune, null: false                               #Unique symbol to appear in daimon's eye
      t.string :effect                                          #Defines what type of challenge the daimon provides
      t.string :effect_type, null: false                        #Defines if it's "damage", "healing", "misc"
      t.integer :progression_level, default: 0, null: false     #Required lore progression to fight this daimon

      #Single dialogue lines
      t.text :intro, null: false                                #Introductin of the daimon 
      t.text :player_win, null: false                           #Line if the player wins the round
      t.text :player_lose, null: false                          #Line if the player loses the round

      #JSON for multiple taunts
      t.json :taunts, default: []

      t.timestamps
    end
  end
end
