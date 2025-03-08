class CreateTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :tokens do |t|
      t.string :name, null: false                              #Name of token
      t.string :rune, null: false                              #Unique symbol to appear on token
      t.text :description, null: false                         #Token lore description
      t.string :effect_type, null: false                       #Defintes if it's "damage", "healing", "misc"

      #Slot-specific effects
      t.text :inscribed_effect, null: false                    #Effect of token if placed in inscribed slot
      t.text :oathbound_effect, null: false                    #Effect of token if placed in oathbound slot
      t.text :offering_effect, null: false                     #Effect of token if placed in offering slot

      #Lore Token Attributes
      t.boolean :lore_token, default: false, null: false       #Boolean if token is a story related toke
      t.integer :sequence_order, null: true                    #If it's a lore token, the order in which it appears in the story

      t.timestamps
    end

    add_index :tokens, :effect_type
    add_index :tokens, :lore_token
    add_index :tokens, :sequence_order, unique: true, where: "lore_token = true"
  end
end
