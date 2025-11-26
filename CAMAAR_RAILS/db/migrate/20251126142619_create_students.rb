class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.boolean :registered
      t.string :senha
      t.string :nome
      t.string :curso
      t.string :matricula
      t.string :departamento
      t.string :formacao
      t.string :usuario
      t.string :email
      t.string :ocupacao

      t.timestamps
    end
  end
end
