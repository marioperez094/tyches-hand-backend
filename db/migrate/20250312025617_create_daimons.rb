class CreateDaimons < ActiveRecord::Migration[7.2]
  def change
    create_table :daimons do |t|
      t.string :name, null: false                               #Name of the daimon
      t.string :rune                                            #Unique symbol to appear in daimon's eye
      t.text :description                                       #Describes the challenge and lore of the daimon
      t.integer :story_sequence, default: 0, null: false        #Required lore progression to fight this daimon

      t.string :effect_type, null: false                        #Defines if it's "damage", "healing", "misc"
      t.column :effect_values, :jsonb, default: {}

      #Single dialogue lines
      t.text :intro, null: false                                #Introductin of the daimon 
      t.text :player_win, null: false                           #Line if the player wins the round
      t.text :player_lose, null: false                          #Line if the player loses the round

      #JSON for in game dialogue
      t.json :dialogue, default: []

      t.timestamps
    end
  end
end
