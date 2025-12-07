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

ActiveRecord::Schema[8.0].define(version: 2025_12_07_162638) do
  create_table "administradors", force: :cascade do |t|
    t.string "nome"
    t.string "departamento"
    t.string "formacao"
    t.string "usuario"
    t.string "email"
    t.string "ocupacao"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alunos", force: :cascade do |t|
    t.string "nome"
    t.string "curso"
    t.string "matricula"
    t.string "departamento"
    t.string "formacao"
    t.string "usuario"
    t.string "email"
    t.string "ocupacao"
    t.boolean "registered"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disciplinas", force: :cascade do |t|
    t.string "codigo"
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "formularios", force: :cascade do |t|
    t.integer "administrador_id", null: false
    t.integer "template_id", null: false
    t.integer "turma_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrador_id"], name: "index_formularios_on_administrador_id"
    t.index ["template_id"], name: "index_formularios_on_template_id"
    t.index ["turma_id"], name: "index_formularios_on_turma_id"
  end

  create_table "pergunta", force: :cascade do |t|
    t.integer "template_id", null: false
    t.integer "formulario_id"
    t.string "texto"
    t.string "resposta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["formulario_id"], name: "index_pergunta_on_formulario_id"
    t.index ["template_id"], name: "index_pergunta_on_template_id"
  end

  create_table "professors", force: :cascade do |t|
    t.string "nome"
    t.string "departamento"
    t.string "formacao"
    t.string "usuario"
    t.string "email"
    t.string "ocupacao"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.integer "administrador_id", null: false
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrador_id"], name: "index_templates_on_administrador_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.integer "professor_id", null: false
    t.integer "disciplina_id", null: false
    t.integer "formulario_id", null: false
    t.string "semestre"
    t.string "horario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disciplina_id"], name: "index_turmas_on_disciplina_id"
    t.index ["formulario_id"], name: "index_turmas_on_formulario_id"
    t.index ["professor_id"], name: "index_turmas_on_professor_id"
  end

  add_foreign_key "formularios", "administradors"
  add_foreign_key "formularios", "templates"
  add_foreign_key "formularios", "turmas"
  add_foreign_key "pergunta", "formularios", on_delete: :nullify
  add_foreign_key "pergunta", "templates"
  add_foreign_key "templates", "administradors"
  add_foreign_key "turmas", "disciplinas"
  add_foreign_key "turmas", "formularios"
  add_foreign_key "turmas", "professors"
end
