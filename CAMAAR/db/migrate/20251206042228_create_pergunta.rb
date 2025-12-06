class CreatePergunta < ActiveRecord::Migration[8.0]
  def change
    create_table :pergunta do |t|
      t.references :template, null: false, foreign_key: true
      t.references :formulario, null: false, foreign_key: true
      t.string :texto
      t.string :resposta

      t.timestamps
    end
  end
end
