class CreateTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :tokens do |t|
      t.string :name, null: false                              #Name of token
      t.string :rune, null: false                              #Unique symbol to appear on token
      t.text :description, null: false                         #Token lore description

      ### Slot-specific effects

      #Inscribed effects
      t.string :inscribed_effect_type, null: false             #Effect of token if placed in inscribed slot
      t.column :inscribed_effect_values, :jsonb, default: {}

      #Oathbound effects
      t.string :oathbound_effect_type, null: false             #Effect of token if placed in oathbound slot
      t.column :oathbound_effect_values, :jsonb, default: {}

      #Offering effects
      t.string :offering_effect_type, null: false              #Effect of token if placed in offering slot
      t.column :offering_effect_values, :jsonb, default: {}

      #Lore Token Attributes
      t.boolean :story_token, default: false, null: false       #Boolean if token is a story related toke
      t.integer :story_sequence, null: true                    #If it's a lore token, the order in which it appears in the story

      t.timestamps
    end
    
    add_index :tokens, :story_token
    add_index :tokens, :story_sequence, unique: true, where: "story_token = true"
  end
end
