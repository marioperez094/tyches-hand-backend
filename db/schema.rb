# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_02_25_022155) do
  create_table "card_collections", force: :cascade do |t|
    t.integer "player_id"
    t.integer "card_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_collections_on_card_id"
    t.index ["player_id", "card_id"], name: "index_card_collections_on_player_id_and_card_id", unique: true
    t.index ["player_id"], name: "index_card_collections_on_player_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "suit", null: false
    t.string "rank", null: false
    t.text "description", null: false
    t.string "effect", null: false
    t.string "effect_type", null: false
    t.string "effect_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect"], name: "index_cards_on_effect"
    t.index ["rank"], name: "index_cards_on_rank"
    t.index ["suit"], name: "index_cards_on_suit"
  end

  create_table "decks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_decks_on_player_id", unique: true
  end

  create_table "equipped_cards", force: :cascade do |t|
    t.integer "card_id"
    t.integer "deck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "deck_id"], name: "index_equipped_cards_on_card_id_and_deck_id", unique: true
    t.index ["card_id"], name: "index_equipped_cards_on_card_id"
    t.index ["deck_id"], name: "index_equipped_cards_on_deck_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest"
    t.boolean "is_guest", default: false, null: false
    t.boolean "tutorial_finished", default: false, null: false
    t.integer "blood_pool", default: 5000, null: false
    t.integer "max_daimon_health_reached", default: 0, null: false
    t.integer "max_round_reached", default: 0, null: false
    t.integer "lore_progression", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["max_daimon_health_reached", "max_round_reached"], name: "index_players_on_max_daimon_health_and_round"
    t.index ["max_daimon_health_reached"], name: "index_players_on_max_daimon_health_reached"
    t.index ["max_round_reached"], name: "index_players_on_max_round_reached"
    t.index ["username"], name: "index_players_on_username", unique: true
  end

  add_foreign_key "card_collections", "cards", on_delete: :cascade
  add_foreign_key "card_collections", "players", on_delete: :cascade
  add_foreign_key "decks", "players", on_delete: :cascade
  add_foreign_key "equipped_cards", "cards", on_delete: :cascade
  add_foreign_key "equipped_cards", "decks", on_delete: :cascade
end
