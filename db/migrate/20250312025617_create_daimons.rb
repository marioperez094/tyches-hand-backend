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
      t.json :intro, default: [], null: false                                #Introductin of the daimon 
      t.json :player_win, default: [], null: false                           #Line if the player wins the round

      #JSON for in game dialogue
      t.column :dialogue, :jsonb, default: {}

      t.timestamps
    end
  end
end
