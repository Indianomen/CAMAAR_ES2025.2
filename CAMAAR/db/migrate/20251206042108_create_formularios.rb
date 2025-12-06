class CreateFormularios < ActiveRecord::Migration[8.0]
  def change
    create_table :formularios do |t|
      t.references :administrador, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.references :turma, null: false, foreign_key: true

      t.timestamps
    end
  end
end
