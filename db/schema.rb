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

ActiveRecord::Schema[7.2].define(version: 2025_03_16_204512) do
  create_table "card_collections", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "card_id", null: false
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
    t.json "effect_values"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect"], name: "index_cards_on_effect"
    t.index ["rank"], name: "index_cards_on_rank"
    t.index ["suit"], name: "index_cards_on_suit"
  end

  create_table "daimons", force: :cascade do |t|
    t.string "name", null: false
    t.string "rune"
    t.text "description"
    t.integer "story_sequence", default: 0, null: false
    t.string "effect_type", null: false
    t.json "effect_values", default: {}
    t.text "intro", null: false
    t.text "player_win", null: false
    t.text "player_lose", null: false
    t.json "dialogue", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_decks_on_player_id", unique: true
  end

  create_table "equipped_cards", force: :cascade do |t|
    t.integer "deck_id", null: false
    t.integer "card_collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_collection_id", "deck_id"], name: "index_equipped_cards_on_card_collection_id_and_deck_id", unique: true
    t.index ["card_collection_id"], name: "index_equipped_cards_on_card_collection_id"
    t.index ["deck_id"], name: "index_equipped_cards_on_deck_id"
  end

  create_table "equipped_tokens", force: :cascade do |t|
    t.integer "token_collection_id", null: false
    t.integer "slot_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slot_id"], name: "index_equipped_tokens_on_slot_id"
    t.index ["token_collection_id", "slot_id"], name: "index_equipped_tokens_on_token_collection_id_and_slot_id", unique: true
    t.index ["token_collection_id"], name: "index_equipped_tokens_on_token_collection_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "daimon_progress", default: -1, null: false
    t.integer "rounds_played", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "total_hands_won", default: 0, null: false
    t.integer "total_hands_lost", default: 0, null: false
    t.integer "win_streak", default: 0, null: false
    t.integer "longest_win_streak", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_games_on_player_id"
  end

  create_table "hands", force: :cascade do |t|
    t.integer "round_id", null: false
    t.integer "blood_wager", default: 1000, null: false
    t.json "player_hand", default: []
    t.json "daimon_hand", default: []
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["round_id"], name: "index_hands_on_round_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest"
    t.boolean "is_guest", default: false, null: false
    t.boolean "tutorial_finished", default: false, null: false
    t.integer "blood_pool", default: 5000, null: false
    t.integer "story_progression", default: 0, null: false
    t.integer "max_daimon_health_reached", default: 0, null: false
    t.integer "max_round_reached", default: 0, null: false
    t.integer "games_played", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["max_daimon_health_reached", "max_round_reached"], name: "index_players_on_max_daimon_health_and_round"
    t.index ["max_daimon_health_reached"], name: "index_players_on_max_daimon_health_reached"
    t.index ["max_round_reached"], name: "index_players_on_max_round_reached"
    t.index ["username"], name: "index_players_on_username", unique: true
  end

  create_table "rounds", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "daimon_id", null: false
    t.integer "hands_played", default: 0, null: false
    t.integer "card_count", default: 0, null: false
    t.json "shuffled_deck", default: []
    t.json "discard_pile", default: []
    t.integer "player_max_blood_pool", default: 5000, null: false
    t.integer "daimon_max_blood_pool", null: false
    t.integer "daimon_blood_pool", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daimon_id"], name: "index_rounds_on_daimon_id"
    t.index ["game_id"], name: "index_rounds_on_game_id"
  end

  create_table "slots", force: :cascade do |t|
    t.string "slot_type", null: false
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_slots_on_player_id"
  end

  create_table "token_collections", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "token_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "token_id"], name: "index_token_collections_on_player_id_and_token_id", unique: true
    t.index ["player_id"], name: "index_token_collections_on_player_id"
    t.index ["token_id"], name: "index_token_collections_on_token_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "name", null: false
    t.string "rune", null: false
    t.text "description", null: false
    t.string "inscribed_effect_type", null: false
    t.json "inscribed_effect_values", default: {}
    t.string "oathbound_effect_type", null: false
    t.json "oathbound_effect_values", default: {}
    t.string "offering_effect_type", null: false
    t.json "offering_effect_values", default: {}
    t.boolean "story_token", default: false, null: false
    t.integer "story_sequence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_sequence"], name: "index_tokens_on_story_sequence", unique: true, where: "story_token = true"
    t.index ["story_token"], name: "index_tokens_on_story_token"
  end

  add_foreign_key "card_collections", "cards", on_delete: :cascade
  add_foreign_key "card_collections", "players", on_delete: :cascade
  add_foreign_key "decks", "players", on_delete: :cascade
  add_foreign_key "equipped_cards", "card_collections", on_delete: :cascade
  add_foreign_key "equipped_cards", "decks", on_delete: :cascade
  add_foreign_key "equipped_tokens", "slots", on_delete: :cascade
  add_foreign_key "equipped_tokens", "token_collections", on_delete: :cascade
  add_foreign_key "games", "players", on_delete: :cascade
  add_foreign_key "hands", "rounds", on_delete: :cascade
  add_foreign_key "rounds", "daimons", on_delete: :cascade
  add_foreign_key "rounds", "games", on_delete: :cascade
  add_foreign_key "slots", "players", on_delete: :cascade
  add_foreign_key "token_collections", "players", on_delete: :cascade
  add_foreign_key "token_collections", "tokens", on_delete: :cascade
end
