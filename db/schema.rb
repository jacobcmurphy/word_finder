# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 201607083) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pronunciations", force: :cascade do |t|
    t.integer "word_id"
    t.integer "primary_stress"
    t.integer "secondary_stress"
    t.string  "cmu_notation"
    t.index ["word_id"], name: "index_pronunciations_on_word_id", using: :btree
  end

  create_table "syllable_counts", force: :cascade do |t|
    t.integer "word_id"
    t.integer "number_of_syllables"
    t.index ["number_of_syllables"], name: "index_syllable_counts_on_number_of_syllables", using: :btree
    t.index ["word_id"], name: "index_syllable_counts_on_word_id", using: :btree
  end

  create_table "word_types", force: :cascade do |t|
    t.integer "word_id"
    t.string  "part_of_speech"
    t.index ["word_id"], name: "index_word_types_on_word_id", using: :btree
  end

  create_table "words", force: :cascade do |t|
    t.string "word"
    t.index ["word"], name: "index_words_on_word", using: :btree
  end

end
