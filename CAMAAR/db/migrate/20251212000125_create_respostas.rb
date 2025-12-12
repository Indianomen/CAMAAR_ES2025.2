class CreateRespostas < ActiveRecord::Migration[8.0]
  def change
    create_table :respostas do |t|
      t.references :aluno, null: false, foreign_key: true
      t.references :pergunta, null: false, foreign_key: true
      t.text :texto

      t.timestamps
    end
  end
end
