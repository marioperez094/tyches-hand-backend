class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards do |t|
      t.string :name, null: false          #Name of card including effect, rank, and suit
      t.string :suit, null: false          #Suit of the card
      t.string :rank, null: false          #Value of the card
      t.text :description, null: false     #Card description including effects
      t.string :effect, null: false        #Category of the effect
      t.string :effect_type, null: false   #Defines if its "damage", "healing", "misc"
      t.string :effect_description         #Defines the effect of the card
      t.timestamps
    end
    
    add_index :cards, :suit
    add_index :cards, :rank
    add_index :cards, :effect
  end
end
