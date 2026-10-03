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

ActiveRecord::Schema[8.1].define(version: 2026_10_03_041417) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "partituras", force: :cascade do |t|
    t.string "titulo", null: false
    t.string "autor", null: false
    t.string "arranjador", null: false
    t.integer "bpm"
    t.string "tonalidade", limit: 10, null: false
    t.integer "avaliacao"
    t.date "data_criacao", default: -> { "CURRENT_DATE" }, null: false
    t.index ["titulo", "autor"], name: "index_partituras_on_titulo_and_autor"
    t.check_constraint "avaliacao >= 1 AND avaliacao <= 5", name: "check_avaliacao_range"
    t.check_constraint "bpm > 0", name: "check_bpm_positive"
    t.check_constraint "tonalidade::text = ANY (ARRAY['C'::character varying::text, 'C#'::character varying::text, 'D'::character varying::text, 'D#'::character varying::text, 'E'::character varying::text, 'F'::character varying::text, 'F#'::character varying::text, 'G'::character varying::text, 'G#'::character varying::text, 'A'::character varying::text, 'A#'::character varying::text, 'B'::character varying::text, 'Cm'::character varying::text, 'C#m'::character varying::text, 'Dm'::character varying::text, 'D#m'::character varying::text, 'Em'::character varying::text, 'Fm'::character varying::text, 'F#m'::character varying::text, 'Gm'::character varying::text, 'G#m'::character varying::text, 'Am'::character varying::text, 'A#m'::character varying::text, 'Bm'::character varying::text])", name: "check_tonalidade_sigla"
  end
end
