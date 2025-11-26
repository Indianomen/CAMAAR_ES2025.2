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

ActiveRecord::Schema[8.0].define(version: 2025_11_26_142631) do
  create_table "admins", force: :cascade do |t|
    t.string "senha"
    t.string "nome"
    t.string "departamento"
    t.string "formacao"
    t.string "usuario"
    t.string "email"
    t.string "ocupacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "classesses", force: :cascade do |t|
    t.integer "professor_ID"
    t.integer "disciplina_ID"
    t.integer "form_ID"
    t.string "semestre"
    t.string "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forms", force: :cascade do |t|
    t.integer "administrator_ID"
    t.integer "template_ID"
    t.integer "turma_ID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "professors", force: :cascade do |t|
    t.string "senha"
    t.string "nome"
    t.string "departamento"
    t.string "formacao"
    t.string "usuario"
    t.string "email"
    t.string "ocupacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer "form_ID"
    t.integer "template_ID"
    t.string "texto"
    t.string "resposta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.boolean "registered"
    t.string "senha"
    t.string "nome"
    t.string "curso"
    t.string "matricula"
    t.string "departamento"
    t.string "formacao"
    t.string "usuario"
    t.string "email"
    t.string "ocupacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.integer "administrator_ID"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
